# Setup Guide for GitHub Container Registry

This guide will help you set up automated Docker image publishing to GitHub Container Registry (GHCR).

## Prerequisites

- A GitHub account
- A GitHub repository containing this code
- Git installed on your local machine

## Step-by-Step Setup

### 1. Push Your Code to GitHub

If you haven't already, create a new repository on GitHub and push your code:

```bash
# If you haven't initialized git yet
git init
git add .
git commit -m "Initial commit with Langfuse Vault integration"

# Add your GitHub repository as remote
git remote add origin https://github.com/<your-username>/langfuse-image.git

# Push to GitHub
git push -u origin main
```

### 2. Enable GitHub Actions

GitHub Actions is enabled by default for all repositories, but let's verify:

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. If prompted, click "I understand my workflows, go ahead and enable them"

### 3. Verify Workflow is Active

1. Go to the "Actions" tab in your repository
2. You should see "Build and Publish Docker Images" in the workflows list
3. If you just pushed the code, the workflow should be running automatically

### 4. Check the First Build

1. Click on "Build and Publish Docker Images" in the Actions tab
2. Click on the latest workflow run
3. Watch the build progress
4. Once complete, you should see a green checkmark ✓

### 5. Find Your Published Image

After the first successful build:

1. Go to your GitHub profile (click your avatar → "Your profile")
2. Click on the "Packages" tab
3. You should see `langfuse-image` package listed
4. Click on it to see available tags and instructions

### 6. Make Your Image Public (Optional)

By default, your image is private. To make it public:

1. On your package page, click "Package settings" (right sidebar)
2. Scroll down to "Danger Zone"
3. Click "Change visibility"
4. Select "Public"
5. Type the repository name to confirm
6. Click "I understand, change package visibility"

### 7. Test Pulling Your Image

Once published, test pulling your image:

**For public images:**
```bash
docker pull ghcr.io/<your-username>/langfuse-image:latest
```

**For private images:**
```bash
# Create a Personal Access Token (PAT) first:
# Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
# Click "Generate new token (classic)"
# Select scope: read:packages
# Generate and copy the token

# Login to GHCR
echo YOUR_TOKEN | docker login ghcr.io -u <your-username> --password-stdin

# Pull the image
docker pull ghcr.io/<your-username>/langfuse-image:latest
```

### 8. Run Your Image

```bash
docker run -d \
  --name langfuse \
  -p 3000:3000 \
  -v /path/to/your/vault/secrets:/vault/secrets:ro \
  --restart unless-stopped \
  ghcr.io/<your-username>/langfuse-image:latest
```

## Publishing New Versions

### Method 1: Automatic (Recommended)

Simply push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Action will automatically build and publish with proper version tags.

### Method 2: Manual Trigger

1. Go to "Actions" tab in your repository
2. Click "Build and Publish Docker Images"
3. Click "Run workflow"
4. Select branch (usually `main`)
5. Click "Run workflow" button

## Troubleshooting

### Issue: Workflow Doesn't Run

**Solution:**
1. Check if GitHub Actions is enabled (Actions tab)
2. Verify the workflow file is in `.github/workflows/` directory
3. Check if the file has correct YAML syntax

### Issue: Build Fails

**Solution:**
1. Click on the failed workflow run in the Actions tab
2. Expand the failed step to see the error message
3. Common issues:
   - Missing files (e.g., `vault-entrypoint.sh`)
   - Invalid Dockerfile syntax
   - Base image not available

### Issue: Cannot Pull Image

**Solution:**
1. Verify the image name is correct: `ghcr.io/<username>/langfuse-image:tag`
2. Check if the image is private (requires authentication)
3. Ensure you're using the correct tag (check Packages page)
4. If private, authenticate first with `docker login ghcr.io`

### Issue: Permission Denied When Pushing

**Solution:**
This shouldn't happen with `GITHUB_TOKEN`, but if it does:
1. Check repository settings → Actions → General
2. Ensure "Read and write permissions" is enabled for workflows
3. Save the settings

### Issue: Image Size Too Large

**Solution:**
1. Review what's being copied into the image
2. Use `.dockerignore` to exclude unnecessary files
3. Consider multi-stage builds if needed
4. Clear build cache: Docker → Preferences → Resources → Advanced → Clear cache

## Advanced Configuration

### Building for Different Platforms

Edit `.github/workflows/publish-docker.yml` and modify the `platforms` line:

```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

### Adding Build Arguments

Add build arguments in the workflow:

```yaml
build-args: |
  VERSION=${{ github.ref_name }}
  BUILD_DATE=${{ github.event.head_commit.timestamp }}
```

Then use them in your Dockerfile:

```dockerfile
ARG VERSION
ARG BUILD_DATE
LABEL version=$VERSION
LABEL build-date=$BUILD_DATE
```

### Custom Image Name

By default, the image name matches your repository name. To change it, edit the workflow:

```yaml
env:
  IMAGE_NAME: <your-custom-name>
```

## Best Practices

1. **Use Semantic Versioning**: `v1.0.0`, `v1.1.0`, `v2.0.0`
2. **Tag Releases**: Use Git tags to trigger builds
3. **Document Changes**: Use GitHub Releases to document version changes
4. **Pin Versions in Production**: Use specific tags like `v1.0.0` instead of `latest`
5. **Test Before Deploying**: Use PR builds to test changes before merging
6. **Keep Secrets Secure**: Never commit secrets to the repository
7. **Regular Updates**: Keep base images and dependencies updated

## Getting Help

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **GitHub Container Registry**: https://docs.github.com/en/packages
- **Docker Documentation**: https://docs.docker.com/

## Next Steps

- ✅ Set up automated builds
- ✅ Publish your first image
- ✅ Test pulling and running the image
- 📝 Create your first vault secrets
- 🚀 Deploy to production
- 📊 Monitor your application
- 🔄 Set up automatic updates

Happy deploying! 🎉

