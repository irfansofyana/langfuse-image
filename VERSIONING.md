# Versioning Strategy

This document outlines the versioning strategy for the custom Langfuse image with Vault integration.

## Version Naming Convention

We use a **dual-version approach** that tracks both the base Langfuse version and our custom modifications:

### Format: `v{CUSTOM_VERSION}-langfuse{LANGFUSE_VERSION}`

Examples:
- `v1.0.0-langfuse3.116` - Custom version 1.0.0 based on Langfuse 3.116
- `v1.1.0-langfuse3.116` - Custom version 1.1.0 based on Langfuse 3.116
- `v2.0.0-langfuse3.117` - Custom version 2.0.0 based on Langfuse 3.117

## Versioning Components

### 1. Langfuse Base Version
The official Langfuse version used as the base image. This is specified in:
- `Dockerfile` as `ARG LANGFUSE_VERSION=3.116`
- GitHub Actions workflow as `LANGFUSE_VERSION` env variable
- Git tags (as suffix)

### 2. Custom Version
Your modifications to the Langfuse image. Follow semantic versioning:
- **Major (X.0.0)**: Breaking changes to the vault integration or entrypoint
- **Minor (0.X.0)**: New features (e.g., additional vault features, new env handling)
- **Patch (0.0.X)**: Bug fixes, documentation updates

## Workflow for Version Updates

### Scenario 1: Update to a New Langfuse Version (No Custom Changes)

When Langfuse releases a new version and you want to use it:

```bash
# 1. Update Dockerfile
# Edit langfuse-web/Dockerfile
ARG LANGFUSE_VERSION=3.117  # Update this

# 2. Update GitHub Actions default
# Edit .github/workflows/publish-docker.yml
LANGFUSE_VERSION: ${{ github.event.inputs.langfuse_version || '3.117' }}

# 3. Test the build
cd langfuse-web
./build.sh 3.117

# 4. Tag and push
git add .
git commit -m "chore: update to Langfuse 3.117"
git tag v1.0.1-langfuse3.117
git push origin main
git push origin v1.0.1-langfuse3.117
```

### Scenario 2: Custom Modifications (Same Langfuse Version)

When you make changes to vault integration or entrypoint:

```bash
# 1. Make your changes to vault-entrypoint.sh or other files

# 2. Test locally
cd langfuse-web
./build.sh 3.116

# 3. Tag with incremented custom version
git add .
git commit -m "feat: add support for custom vault path"
git tag v1.1.0-langfuse3.116
git push origin main
git push origin v1.1.0-langfuse3.116
```

### Scenario 3: Both Updates at Once

```bash
# Update Langfuse version AND make custom changes
git tag v2.0.0-langfuse3.117
git push origin v2.0.0-langfuse3.117
```

## Published Image Tags

Each version creates multiple tags in GHCR for easier consumption:

### From Git Tag: `v1.2.3-langfuse3.116`
Publishes as:
- `ghcr.io/irfansofyana/langfuse-web:v1.2.3-langfuse3.116` (full version)
- `ghcr.io/irfansofyana/langfuse-web:v1.2.3` (custom version only)
- `ghcr.io/irfansofyana/langfuse-web:v1.2` (major.minor)
- `ghcr.io/irfansofyana/langfuse-web:v1` (major)
- `ghcr.io/irfansofyana/langfuse-web:latest` (on main branch)
- `ghcr.io/irfansofyana/langfuse-web:langfuse3.116` (Langfuse version)

### From Branch Push: `main`
- `ghcr.io/irfansofyana/langfuse-web:main`
- `ghcr.io/irfansofyana/langfuse-web:latest`

## Docker Image Labels

All images include OCI labels with metadata:
- `org.opencontainers.image.version`: The full version tag
- `org.opencontainers.image.revision`: Git commit SHA
- `org.opencontainers.image.created`: Build timestamp
- `org.opencontainers.image.source`: GitHub repository URL
- `langfuse.base.version`: The Langfuse version used

## Best Practices

1. **Always test locally first** using `./build.sh {version}` before tagging
2. **Document breaking changes** in commit messages and CHANGELOG
3. **Keep Langfuse version in sync** with your production needs
4. **Use descriptive commit messages** that explain why the version changed
5. **Update README.md** examples when you bump the default version

## Checking Current Versions

### In Your Repository
```bash
# See all version tags
git tag -l

# See current Dockerfile version
grep "ARG LANGFUSE_VERSION" langfuse-web/Dockerfile
```

### Published Images
```bash
# List all published tags
docker pull ghcr.io/irfansofyana/langfuse-web:latest
docker image inspect ghcr.io/irfansofyana/langfuse-web:latest | jq '.[0].Config.Labels'

# Check specific version
docker pull ghcr.io/irfansofyana/langfuse-web:v1.0.0-langfuse3.116
```

## Migration Between Versions

When upgrading the Langfuse base version, review:
1. [Langfuse Release Notes](https://github.com/langfuse/langfuse/releases)
2. Breaking changes in environment variables
3. Changes in the base image entrypoint
4. Test your vault integration still works correctly

## Rollback Strategy

To rollback to a previous version:

```bash
# Pull the previous version
docker pull ghcr.io/irfansofyana/langfuse-web:v1.0.0-langfuse3.115

# Update your deployment to use the older tag
# OR locally checkout the tag and rebuild
git checkout v1.0.0-langfuse3.115
cd langfuse-web
./build.sh 3.115
```
