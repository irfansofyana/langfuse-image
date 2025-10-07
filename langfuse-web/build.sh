#!/bin/bash

# Default Langfuse version
LANGFUSE_VERSION=${1:-3.116}

# Build the custom Langfuse image with vault integration
docker build \
  --build-arg LANGFUSE_VERSION=${LANGFUSE_VERSION} \
  -t langfuse-vault:${LANGFUSE_VERSION} \
  -t langfuse-vault:latest \
  .

echo "Image built successfully as langfuse-vault:${LANGFUSE_VERSION} and langfuse-vault:latest"
echo ""
echo "To test the image locally:"
echo "docker run -p 3000:3000 langfuse-vault:${LANGFUSE_VERSION}"
echo ""
echo "To test with vault secrets directory:"
echo "docker run -p 3000:3000 -v /path/to/secrets:/vault/secrets langfuse-vault:${LANGFUSE_VERSION}"
echo ""
echo "To build with a different Langfuse version:"
echo "./build.sh 3.115"