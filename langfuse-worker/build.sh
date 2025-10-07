#!/bin/bash

# Default Langfuse version
LANGFUSE_VERSION=${1:-3.116}

# Build the custom Langfuse worker image with vault integration
docker build \
  --build-arg LANGFUSE_VERSION=${LANGFUSE_VERSION} \
  -t langfuse-worker:${LANGFUSE_VERSION} \
  -t langfuse-worker:latest \
  .

echo "Image built successfully as langfuse-worker:${LANGFUSE_VERSION} and langfuse-worker:latest"
echo ""
echo "To test the image locally:"
echo "docker run -p 3030:3030 langfuse-worker:${LANGFUSE_VERSION}"
echo ""
echo "To test with vault secrets directory:"
echo "docker run -p 3030:3030 -v /path/to/secrets:/vault/secrets langfuse-worker:${LANGFUSE_VERSION}"
echo ""
echo "To build with a different Langfuse version:"
echo "./build.sh 3.115"
