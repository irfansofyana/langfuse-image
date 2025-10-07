# Use the official Langfuse image as base
ARG LANGFUSE_VERSION=3.116
FROM langfuse/langfuse:${LANGFUSE_VERSION}

# Switch to root user to make changes
USER root

# Create the new entrypoint script that will source vault secrets
COPY vault-entrypoint.sh /vault-entrypoint.sh
RUN chmod +x /vault-entrypoint.sh

# Switch back to nextjs user
USER nextjs

# Override the entrypoint to use our vault-aware script
ENTRYPOINT ["dumb-init", "--", "/vault-entrypoint.sh"]

# Keep the same CMD as the original
CMD if [ -n "$NEXT_PUBLIC_LANGFUSE_CLOUD_REGION" ]; then \
    node --import dd-trace/initialize.mjs ./web/server.js --keepAliveTimeout 110000; \
    else \
    node ./web/server.js --keepAliveTimeout 110000; \
    fi