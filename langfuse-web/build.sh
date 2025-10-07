#!/bin/bash

# Build the custom Langfuse image with vault integration
docker build -t langfuse-vault:latest .

echo "Image built successfully as langfuse-vault:latest"
echo ""
echo "To test the image locally:"
echo "docker run -p 3000:3000 langfuse-vault:latest"
echo ""
echo "To test with vault secrets directory:"
echo "docker run -p 3000:3000 -v /path/to/secrets:/vault/secrets langfuse-vault:latest"