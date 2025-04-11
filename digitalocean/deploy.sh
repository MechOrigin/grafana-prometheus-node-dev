#!/bin/bash

# Exit on error
set -e

echo "Starting deployment of monitoring stack to DigitalOcean..."

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create directory structure
echo "Creating directory structure..."
mkdir -p /opt/monitoring/{alertmanager,prometheus,grafana,blackbox}

# Copy configuration files
echo "Copying configuration files..."
# Note: You'll need to manually copy your configuration files to the server
# or use SCP/rsync to transfer them

# Set up firewall
echo "Setting up firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 9093/tcp  # Alertmanager
ufw allow 9090/tcp  # Prometheus
ufw allow 3001/tcp  # Grafana
ufw allow 9115/tcp  # Blackbox exporter
ufw --force enable

# Start services
echo "Starting monitoring services..."
cd /opt/monitoring
docker-compose up -d

echo "Deployment complete!"
echo "Your monitoring stack is now running on this server."
echo "Alertmanager: http://$(hostname -I | awk '{print $1}'):9093"
echo "Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
echo "Grafana: http://$(hostname -I | awk '{print $1}'):3001" 