#!/bin/sh

set -e

VAULT_SECRETS_DIRECTORY=${VAULT_SECRETS_DIRECTORY:-"/vault/secrets"}

echo "Starting Langfuse Worker with Vault secrets integration..."

# Source all .sh files from the vault secrets directory if it exists
if [ -d "${VAULT_SECRETS_DIRECTORY}" ]; then
    echo "Vault secrets directory found: ${VAULT_SECRETS_DIRECTORY}"
    # Use a sh-compatible approach to iterate over files
    for entry in "${VAULT_SECRETS_DIRECTORY}"/*.sh; do
        # Check if the file actually exists (handles case when no .sh files are present)
        if [ -f "$entry" ]; then
            echo "Sourcing vault secret: $entry"
            . "$entry"
        fi
    done
    echo "Finished sourcing vault secrets"
else
    echo "Vault secrets directory not found: ${VAULT_SECRETS_DIRECTORY}"
fi

# Execute the original Langfuse worker entrypoint script if it exists, otherwise run the command directly
echo "Executing Langfuse Worker..."
if [ -f "./worker/entrypoint.sh" ]; then
    echo "Using worker entrypoint script"
    exec ./worker/entrypoint.sh "$@"
else
    echo "Running worker command directly"
    exec "$@"
fi
