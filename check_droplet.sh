#!/bin/bash

# Exit on error
set -e

# Check if DO_API_TOKEN is set
if [ -z "$DO_API_TOKEN" ]; then
    echo "Error: DO_API_TOKEN environment variable is not set"
    echo "Please set it with: export DO_API_TOKEN=your_api_token"
    exit 1
fi

# Droplet ID (you'll need to replace this with your actual droplet ID)
DROPLET_ID="your_droplet_id"

echo "Checking droplet status..."

# Get droplet status
curl -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DO_API_TOKEN" \
    "https://api.digitalocean.com/v2/droplets/$DROPLET_ID"

echo "Check complete!" 