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
				const command = `yt-dlp --write-auto-subs --sub-langs ${language} --skip-download --sub-format srt "${url}"`;

				// Execute yt-dlp command
				execSync(command, { stdio: 'pipe' });

				// Find the generated .srt file
				const files = readdirSync('.');
				const srtFile = files.find(file => file.includes(videoId) && file.endsWith(`.${language}.srt`));

				if (!srtFile) {
					throw new NodeOperationError(this.getNode(), `No transcript found for language: ${language}`);
				}

				// Read and parse the SRT file
				const srtContent = readFileSync(srtFile, 'utf8');
				
				let result: string | Array<{text: string, start: string, end: string}>;
				if (outputFormat === 'json') {
					result = parseSRTWithTimestamps(srtContent);
				} else {
					result = parseSRTToText(srtContent);
				}

				// Clean up the file
				unlinkSync(srtFile);

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