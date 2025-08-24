import {
	IExecuteFunctions,
	INodeExecutionData,
	INodeType,
	INodeTypeDescription,
	NodeOperationError,
	NodeConnectionType,
} from 'n8n-workflow';
import { execSync } from 'child_process';
import { readFileSync, unlinkSync, readdirSync } from 'fs';

export class HylyYouTubeNode implements INodeType {
	description: INodeTypeDescription = {
		displayName: 'Hyly YouTube Node',
		name: 'hylyYouTubeNode',
		icon: 'file:youtube.svg',
		group: ['transform'],
		version: 1,
		description: 'Extract transcripts from YouTube videos using yt-dlp',
		defaults: {
			name: 'Hyly YouTube Node',
		},
		inputs: [NodeConnectionType.Main],
		outputs: [NodeConnectionType.Main],
		properties: [
			{
				displayName: 'Video ID',
				name: 'videoId',
				type: 'string',
				default: '',
				placeholder: 'BmQ706_9wlQ',
				description: 'YouTube video ID (11 characters from the URL)',
				required: true,
			},
			{
				displayName: 'Language',
				name: 'language',
				type: 'string',
				default: 'en',
				description: 'Language code for subtitles (e.g., en, es, fr)',
			},
			{
				displayName: 'Output Format',
				name: 'outputFormat',
				type: 'options',
				options: [
					{
						name: 'Plain Text',
						value: 'text',
					},
					{
						name: 'JSON with Timestamps',
						value: 'json',
					},
				],
				default: 'text',
				description: 'Format of the output transcript',
			},
		],
	};

	async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
		const items = this.getInputData();
		const returnData: INodeExecutionData[] = [];

		for (let i = 0; i < items.length; i++) {
			try {
				const videoId = this.getNodeParameter('videoId', i) as string;
				const language = this.getNodeParameter('language', i) as string;
				const outputFormat = this.getNodeParameter('outputFormat', i) as string;

				if (!videoId || videoId.length !== 11) {
					throw new NodeOperationError(this.getNode(), 'Invalid YouTube video ID. Must be 11 characters long.');
				}

				const url = `https://www.youtube.com/watch?v=${videoId}`;
				const workDir = '/tmp';
				// Try user-installed yt-dlp first, fallback to system yt-dlp
				// Also add --no-check-certificate to bypass some SSL issues
				const ytdlpPath = '/home/node/.local/bin/yt-dlp';
				const fallbackPath = 'yt-dlp';
				const ytdlpCommand = `${ytdlpPath} --version > /dev/null 2>&1 && echo "${ytdlpPath}" || echo "${fallbackPath}"`;
				const ytdlp = execSync(ytdlpCommand, { encoding: 'utf8' }).trim();
				
				const command = `cd ${workDir} && ${ytdlp} --write-auto-subs --sub-langs ${language} --skip-download --sub-format "srt/vtt/best" --no-check-certificate "${url}"`;

				// Execute yt-dlp command
				execSync(command, { stdio: 'pipe' });

				// Find the generated subtitle file (could be .srt or .vtt)
				const files = readdirSync(workDir);
				const subtitleFile = files.find(file => 
					file.includes(videoId) && 
					(file.endsWith(`.${language}.srt`) || 
					 file.endsWith(`.${language}.vtt`) ||
					 file.includes(`.${language}.`) && (file.endsWith('.srt') || file.endsWith('.vtt')))
				);

				if (!subtitleFile) {
					throw new NodeOperationError(this.getNode(), `No transcript found for language: ${language}. Files in ${workDir}: ${files.filter(f => f.includes(videoId)).join(', ')}`);
				}

				// Read and parse the subtitle file
				const subtitlePath = `${workDir}/${subtitleFile}`;
				const subtitleContent = readFileSync(subtitlePath, 'utf8');
				
				let result: string | Array<{text: string, start: string, end: string}>;
				const isVTT = subtitleFile.endsWith('.vtt');
				
				if (outputFormat === 'json') {
					result = isVTT ? parseVTTWithTimestamps(subtitleContent) : parseSRTWithTimestamps(subtitleContent);
				} else {
					result = isVTT ? parseVTTToText(subtitleContent) : parseSRTToText(subtitleContent);
				}

				// Clean up the file
				unlinkSync(subtitlePath);

				returnData.push({
					json: {
						videoId,
						language,
						format: outputFormat,
						transcript: result,
						extractedAt: new Date().toISOString(),
					},
				});

			} catch (error) {
				if (this.continueOnFail()) {
					returnData.push({
						json: {
							error: (error as Error).message,
						},
					});
					continue;
				}
				throw error;
			}
		}

		return [returnData];
	}
}

function parseSRTToText(srtContent: string): string {
	const lines = srtContent.split('\n');
	const textLines: string[] = [];

	for (const line of lines) {
		const trimmedLine = line.trim();
		// Skip sequence numbers, timestamps, and empty lines
		if (trimmedLine && !trimmedLine.match(/^\d+$/) && !trimmedLine.match(/\d{2}:\d{2}:\d{2}/)) {
			textLines.push(trimmedLine);
		}
	}

	return textLines.join(' ').replace(/\s+/g, ' ').trim();
}

function parseSRTWithTimestamps(srtContent: string): Array<{text: string, start: string, end: string}> {
	const blocks = srtContent.split('\n\n');
	const result: Array<{text: string, start: string, end: string}> = [];

	for (const block of blocks) {
		const lines = block.trim().split('\n');
		if (lines.length >= 3) {
			const timeLine = lines[1];
			const text = lines.slice(2).join(' ').trim();
			
			if (timeLine.includes('-->')) {
				const [start, end] = timeLine.split(' --> ');
				result.push({
					text,
					start: start.trim(),
					end: end.trim(),
				});
			}
		}
	}

	return result;
}

function parseVTTToText(vttContent: string): string {
	const lines = vttContent.split('\n');
	const textLines: string[] = [];
	let skipHeader = true;

	for (const line of lines) {
		const trimmedLine = line.trim();
		
		// Skip WEBVTT header
		if (skipHeader && trimmedLine.startsWith('WEBVTT')) {
			skipHeader = false;
			continue;
		}
		
		// Skip timestamps and empty lines
		if (trimmedLine && !trimmedLine.match(/^\d{2}:\d{2}:\d{2}/) && !trimmedLine.includes('-->')) {
			// Remove VTT tags like <c> </c>
			const cleanLine = trimmedLine.replace(/<[^>]*>/g, '');
			if (cleanLine) {
				textLines.push(cleanLine);
			}
		}
	}

	return textLines.join(' ').replace(/\s+/g, ' ').trim();
}

function parseVTTWithTimestamps(vttContent: string): Array<{text: string, start: string, end: string}> {
	const lines = vttContent.split('\n');
	const result: Array<{text: string, start: string, end: string}> = [];
	let i = 0;

	// Skip WEBVTT header
	while (i < lines.length && !lines[i].includes('-->')) {
		i++;
	}

	while (i < lines.length) {
		const line = lines[i].trim();
		
		if (line.includes('-->')) {
			const [start, end] = line.split(' --> ');
			const textLines: string[] = [];
			i++;
			
			// Collect text lines until empty line or next timestamp
			while (i < lines.length && lines[i].trim() && !lines[i].includes('-->')) {
				const cleanLine = lines[i].trim().replace(/<[^>]*>/g, '');
				if (cleanLine) {
					textLines.push(cleanLine);
				}
				i++;
			}
			
			if (textLines.length > 0) {
				result.push({
					text: textLines.join(' '),
					start: start.trim(),
					end: end.trim().split(' ')[0], // Remove VTT position info if present
				});
			}
		}
		i++;
	}

	return result;
}