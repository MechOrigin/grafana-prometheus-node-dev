#!/bin/bash

# Exit on error
set -e

echo "Checking services on DigitalOcean droplet..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please run the deployment script first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please run the deployment script first."
    exit 1
fi

# Check if the monitoring directory exists
if [ ! -d "/opt/monitoring" ]; then
    echo "Monitoring directory does not exist. Please run the deployment script first."
    exit 1
fi

# Check Docker containers
echo "Docker containers:"
docker ps

# Check firewall status
echo "Firewall status:"
ufw status

# Check listening ports
echo "Listening ports:"
netstat -tulpn | grep -E '3001|9090|9093|9115|9100'

docker --version
docker-compose --version

echo "Check complete!"

# Start services
cd /opt/monitoring
docker-compose up -d

# Check if containers are running
docker ps 