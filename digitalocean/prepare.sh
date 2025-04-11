#!/bin/bash

# Exit on error
set -e

echo "Preparing files for DigitalOcean deployment..."

# Create necessary directories
mkdir -p digitalocean/prometheus/rules
mkdir -p digitalocean/alertmanager/templates
mkdir -p digitalocean/blackbox
mkdir -p digitalocean/grafana/provisioning

# Copy Prometheus rules
echo "Copying Prometheus rules..."
cp -r prometheus/rules/* digitalocean/prometheus/rules/

# Copy Alertmanager templates
echo "Copying Alertmanager templates..."
cp -r alertmanager/templates/* digitalocean/alertmanager/templates/

# Copy Blackbox configuration
echo "Copying Blackbox configuration..."
cp -r blackbox/* digitalocean/blackbox/

# Copy Grafana provisioning
echo "Copying Grafana provisioning..."
cp -r grafana/provisioning/* digitalocean/grafana/provisioning/

# Update Alertmanager configuration with Mattermost webhook URL
echo "Please enter your Mattermost webhook URL:"
read webhook_url

# Update the Alertmanager configuration
sed -i '' "s|YOUR_MATTERMOST_WEBHOOK_URL|$webhook_url|g" digitalocean/alertmanager.yml

echo "Files prepared successfully!"
echo "You can now deploy to DigitalOcean using the instructions in digitalocean/README.md" 