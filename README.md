# langfuse-image

Custom Langfuse Docker image with Vault secrets integration.

## Features

- Based on official Langfuse image (v3.116)
- Automatically sources environment variables from Vault secrets directory
- Compatible with Alpine Linux (sh shell)
- Supports mounting secrets from `/vault/secrets` or custom path

## Quick Start

### Using Pre-built Images from GitHub Container Registry

Pull the latest image directly from GHCR:

```bash
docker pull ghcr.io/<your-github-username>/langfuse-image:latest
```

Or use a specific version:

```bash
docker pull ghcr.io/<your-github-username>/langfuse-image:v1.0.0
```

Then run it:

```bash
docker run -d \
  --name langfuse \
  -p 3000:3000 \
  -v /path/to/your/vault/secrets:/vault/secrets:ro \
  --restart unless-stopped \
  ghcr.io/<your-github-username>/langfuse-image:latest
```

### Build the Image Locally

```bash
cd langfuse-web
./build.sh
```

### Test the Integration

Run the automated test script to verify vault secrets are loaded correctly:

```bash
cd langfuse-web
./test-env.sh
```

This will:
1. Build the image
2. Test running without vault secrets
3. Test running with vault secrets mounted
4. Show which environment variables are successfully loaded

### Manual Testing

**Test 1: Run without vault secrets**
```bash
docker run --rm -p 3000:3000 langfuse-vault:3.116
```

**Test 2: Run with test vault secrets**
```bash
cd langfuse-web
docker run --rm -p 3000:3000 \
  -v "$(pwd)/test-secrets:/vault/secrets:ro" \
  langfuse-vault:3.116
```

**Test 3: Check if environment variables are loaded**
```bash
cd langfuse-web
docker run --rm \
  -v "$(pwd)/test-secrets:/vault/secrets:ro" \
  langfuse-vault:3.116 \
  sh -c 'env | grep DATABASE_URL'
```

Expected output: Should show the DATABASE_URL from test-secrets/database.sh

### Custom Vault Secrets Path

You can use a custom path by setting the `VAULT_SECRETS_DIRECTORY` environment variable:

```bash
docker run --rm -p 3000:3000 \
  -e VAULT_SECRETS_DIRECTORY=/custom/path \
  -v /your/secrets/path:/custom/path:ro \
  langfuse-vault:3.116
```

## How It Works

1. The `vault-entrypoint.sh` script runs before the Langfuse application starts
2. It looks for `.sh` files in the vault secrets directory (default: `/vault/secrets`)
3. All found `.sh` files are sourced to export environment variables
4. Then it executes the original Langfuse entrypoint

## Creating Your Own Vault Secrets

Create shell script files (`.sh` extension) in your vault secrets directory:

**Example: `/vault/secrets/database.sh`**
```bash
#!/bin/sh
export DATABASE_URL="postgresql://user:password@host:5432/langfuse"
export NEXTAUTH_URL="https://your-domain.com"
export NEXTAUTH_SECRET="your-secret-key"
export SALT="your-salt-value"
```

Make sure the files are executable:
```bash
chmod +x /vault/secrets/*.sh
```

## CI/CD and Automated Builds

This repository includes a GitHub Actions workflow that automatically builds and publishes Docker images to GitHub Container Registry.

### Automatic Triggers

The workflow runs automatically when:
- **Pushing to main branch**: Creates a `latest` tag
- **Creating version tags**: Creates semantic version tags (e.g., `v1.0.0`, `v1.0`, `v1`)
- **Pull requests**: Builds the image for testing (doesn't publish)

### Manual Trigger

You can also manually trigger a build from the GitHub Actions tab:
1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Select "Build and Publish Docker Images"
4. Click "Run workflow"

### Publishing a New Version

To publish a new version:

```bash
# Tag your release
git tag v1.0.0
git push origin v1.0.0
```

This will automatically build and publish images with the following tags:
- `ghcr.io/<your-username>/langfuse-image:v1.0.0`
- `ghcr.io/<your-username>/langfuse-image:1.0`
- `ghcr.io/<your-username>/langfuse-image:1`
- `ghcr.io/<your-username>/langfuse-image:latest` (if on main branch)

