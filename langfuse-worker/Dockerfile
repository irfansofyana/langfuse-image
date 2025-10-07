# Use the official Langfuse image as base
ARG LANGFUSE_VERSION=3.116
FROM langfuse/langfuse-worker:${LANGFUSE_VERSION}

# Switch to root user to make changes
USER root

# Create the new entrypoint script that will source vault secrets
COPY vault-entrypoint.sh /vault-entrypoint.sh
RUN chmod +x /vault-entrypoint.sh

# Switch back to expressjs user (same as original)
USER expressjs

# Override the entrypoint to use our vault-aware script
ENTRYPOINT ["dumb-init", "--", "/vault-entrypoint.sh"]

# Keep the same CMD as the original worker
CMD ["node", "worker/dist/index.js"]
