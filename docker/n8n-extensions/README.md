# n8n-nodes-youtube-transcript

This is an n8n community node that extracts transcripts from YouTube videos using yt-dlp.

## Installation

### Option 1: Install via n8n Community Nodes

1. Go to n8n Settings → Community Nodes
2. Install: `n8n-nodes-youtube-transcript`

### Option 2: Manual Installation

```bash
# Clone this repository
git clone <repository-url>
cd n8n-youtube-transcript

# Build the node
npm install
npm run build

# Link for local development
npm link
```

### Prerequisites

**Important**: yt-dlp must be installed and available in PATH on the system running n8n:

```bash
# Install yt-dlp
pip install yt-dlp

# Or using curl (Linux/macOS)
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
chmod +x yt-dlp
sudo mv yt-dlp /usr/local/bin/

# Verify installation
yt-dlp --version
```

## Configuration

- **Video ID**: The 11-character YouTube video ID (from URL)
- **Language**: Language code for subtitles (default: en)
- **Output Format**: 
  - Plain Text: Clean transcript without timestamps
  - JSON with Timestamps: Array of objects with text and timing data

## Usage Example

1. Add the YouTube Transcript node to your workflow
2. Enter the video ID: `BmQ706_9wlQ` (from `https://youtube.com/watch?v=BmQ706_9wlQ`)
3. Choose language: `en` (English)
4. Select output format: `Plain Text`
5. Execute the workflow

**Output:**
```json
{
  "videoId": "BmQ706_9wlQ",
  "language": "en", 
  "format": "text",
  "transcript": "If you've ever felt like Performance Max was a black box...",
  "extractedAt": "2025-01-16T10:30:00.000Z"
}
```

## Video ID Examples

| YouTube URL | Video ID |
|-------------|----------|
| `https://youtube.com/watch?v=BmQ706_9wlQ` | `BmQ706_9wlQ` |
| `https://youtu.be/dQw4w9WgXcQ` | `dQw4w9WgXcQ` |

## Supported Languages

Any language code supported by YouTube auto-captions:
- `en` - English
- `es` - Spanish  
- `fr` - French
- `de` - German
- `ja` - Japanese
- And many more...

## Error Handling

- Videos without captions will throw an error
- Invalid video IDs will be rejected
- Network errors are handled gracefully
- Enable "Continue on Fail" to handle errors in batch processing

## License

MIT