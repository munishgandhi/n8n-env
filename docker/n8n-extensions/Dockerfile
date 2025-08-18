FROM n8nio/n8n:latest

USER root

# Install yt-dlp
RUN apk add --no-cache python3 py3-pip curl && \
    pip3 install --break-system-packages yt-dlp

USER node

# Set up temporary package directory
WORKDIR /tmp/hyly-youtube-package
COPY --chown=node:node package.json ./
COPY --chown=node:node dist/ ./dist/
COPY --chown=node:node nodes/YouTubeTranscript/youtube.svg ./dist/nodes/YouTubeTranscript/

# Clean up old YouTube transcript node and install our Hyly node
RUN mkdir -p /home/node/.n8n/nodes && cd /home/node/.n8n/nodes && \
    rm -rf node_modules/n8n-nodes-youtube-transcript && \
    echo '{"name":"installed-nodes","private":true,"dependencies":{"n8n-nodes-hyly-youtube":"file:/tmp/hyly-youtube-package"}}' > package.json && \
    npm install

# Clean up
RUN rm -rf /tmp/hyly-youtube-package

WORKDIR /home/node