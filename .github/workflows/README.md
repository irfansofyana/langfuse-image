# GitHub Actions Workflow Documentation

This document explains the GitHub Actions workflow for building and publishing Docker images to GitHub Container Registry (GHCR).

## Workflow File

Location: `.github/workflows/publish-docker.yml`

## Overview

The workflow automatically builds and publishes your custom Langfuse Docker image with Vault integration to GitHub Container Registry whenever code is pushed or a version tag is created.

## Triggers

The workflow runs on:

### 1. Push Events
- **Branch**: `main`
- **Action**: Builds and publishes with `latest` tag

### 2. Tag Events
- **Pattern**: `v*.*.*` (e.g., `v1.0.0`, `v2.1.3`)
- **Action**: Builds and publishes with semantic version tags

### 3. Pull Requests
- **Branch**: `main`
- **Action**: Builds the image but does NOT publish (for testing)

### 4. Manual Trigger
- **Action**: Can be triggered manually from GitHub Actions tab

## Image Tags

The workflow automatically generates multiple tags based on the trigger:

| Trigger | Generated Tags |
|---------|---------------|
| Push to `main` | `latest`, `main-{git-sha}` |
| Tag `v1.2.3` | `v1.2.3`, `1.2`, `1`, `latest` |
| PR #42 | `pr-42` |
| Branch `feature-x` | `feature-x-{git-sha}` |

## Required Permissions

The workflow requires the following permissions (already configured):
- `contents: read` - To checkout the repository
- `packages: write` - To push to GitHub Container Registry

## Authentication

The workflow uses `GITHUB_TOKEN` which is automatically provided by GitHub Actions. No additional secrets configuration is needed.

## Multi-Platform Builds

The workflow builds images for multiple platforms:
- `linux/amd64` - For Intel/AMD processors
- `linux/arm64` - For ARM processors (including Apple Silicon)

This ensures compatibility across different architectures.

## Build Cache

The workflow uses GitHub Actions cache to speed up builds:
- `cache-from: type=gha` - Uses previous build cache
- `cache-to: type=gha,mode=max` - Saves all layers for future builds

This significantly reduces build time for subsequent runs.

## Usage Examples

### Example 1: Publishing a Major Release

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will create images with tags:
- `ghcr.io/<username>/langfuse-image:v1.0.0`
- `ghcr.io/<username>/langfuse-image:1.0`
- `ghcr.io/<username>/langfuse-image:1`
- `ghcr.io/<username>/langfuse-image:latest`

### Example 2: Publishing a Patch Release

```bash
git tag v1.0.1
git push origin v1.0.1
```

This will create images with tags:
- `ghcr.io/<username>/langfuse-image:v1.0.1`
- `ghcr.io/<username>/langfuse-image:1.0`
- `ghcr.io/<username>/langfuse-image:1`
- `ghcr.io/<username>/langfuse-image:latest`

### Example 3: Testing on Pull Request

When you create a pull request to `main`, the workflow will:
1. Build the Docker image
2. NOT publish it (only validate that it builds successfully)
3. Show the build status on the PR

### Example 4: Manual Build

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Build and Publish Docker Images" workflow
4. Click "Run workflow"
5. Select the branch to build from
6. Click "Run workflow" button

## Accessing Your Images

### Public Images

If your images are public, anyone can pull them:

```bash
docker pull ghcr.io/<username>/langfuse-image:latest
```

### Private Images

If your images are private, you need to authenticate first:

```bash
# Create a Personal Access Token (PAT) with `read:packages` scope
echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin

# Pull the image
docker pull ghcr.io/<username>/langfuse-image:latest
```

## Troubleshooting

### Build Fails

1. Check the Actions tab for error messages
2. Verify that the Dockerfile is valid
3. Ensure all required files (vault-entrypoint.sh) exist

### Cannot Pull Image

1. Verify the image name is correct
2. Check if the image is private (requires authentication)
3. Ensure you have the correct permissions

### Image Not Published

1. Check if the workflow completed successfully
2. Verify you have `packages: write` permission
3. Ensure the trigger conditions were met (push to main or valid tag)

## Customization

### Changing Base Image Version

To update the Langfuse base image version:
1. Edit `langfuse-web/Dockerfile`
2. Change the `FROM langfuse/langfuse:X.XXX` line
3. Commit and push the change

### Adding Additional Build Arguments

To add build arguments, edit `.github/workflows/publish-docker.yml`:

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    build-args: |
      ARG_NAME=value
      ANOTHER_ARG=value
```

### Changing Platforms

To build for different platforms, edit the `platforms` line:

```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

## Best Practices

1. **Use Semantic Versioning**: Tag releases with `v1.0.0`, `v1.1.0`, etc.
2. **Test in PRs**: Create PRs to validate builds before merging
3. **Pin Versions**: Use specific version tags in production (`v1.0.0` instead of `latest`)
4. **Document Changes**: Use GitHub Releases to document what changed in each version
5. **Monitor Builds**: Check the Actions tab regularly for build failures

## Security

- The `GITHUB_TOKEN` is automatically provided and scoped to the repository
- Images are private by default
- Use read-only volume mounts for secrets: `-v /path:/vault/secrets:ro`
- Never commit secrets to the repository

## Cost

- GitHub Actions provides 2,000 free minutes per month for private repositories
- Public repositories have unlimited free minutes
- GitHub Container Registry is free for public images
- Private images have 500MB of free storage

