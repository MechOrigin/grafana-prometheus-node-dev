#!/bin/bash

# Configuration
CLIENT_REPO="dispensariesguide"
ENV_FILE=".env"
GITHUB_TOKEN="{{ salt['pillar.get']('github:token') }}"
REPO_OWNER="{{ salt['pillar.get']('github:owner') }}"

# Function to fetch file content from GitHub
fetch_from_github() {
    local file_path=$1
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         -H "Accept: application/vnd.github.v3.raw" \
         "https://api.github.com/repos/$REPO_OWNER/$CLIENT_REPO/contents/$file_path" | \
    jq -r '.content' | base64 -d
}

# Try to get the key from .env file in the repository
RESEND_KEY=$(fetch_from_github $ENV_FILE | grep RESEND_API_KEY | cut -d '=' -f2)

if [ -z "$RESEND_KEY" ]; then
    echo "Error: Could not find RESEND_API_KEY in the repository"
    exit 1
fi

# Update the Salt pillar with the key
echo "Updating Salt pillar with Resend API key..."
salt-call pillar.set 'resend:api_key' "$RESEND_KEY"

# Verify the update
if [ $? -eq 0 ]; then
    echo "Successfully updated Resend API key in Salt pillar"
else
    echo "Failed to update Resend API key in Salt pillar"
    exit 1
fi 