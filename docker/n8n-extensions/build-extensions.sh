#!/bin/bash

echo "Building n8n extensions..."

# Build the YouTube transcript node (we're already in n8n-extensions)
npm run build

echo "Extensions built successfully!"
echo "Run 'cd .. && docker-compose up --build -d' to deploy."