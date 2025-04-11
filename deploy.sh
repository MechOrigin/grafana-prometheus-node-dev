#!/bin/bash

# Configuration
DROPLET_IP="167.71.155.226"
REMOTE_USER="root"
REMOTE_DIR="/opt/monitoring"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to check if a command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        exit 1
    fi
}

# Function to wait for a service to be ready
wait_for_service() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1

    echo "Waiting for $service to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://${DROPLET_IP}:${port}" > /dev/null; then
            echo -e "${GREEN}✓ $service is ready${NC}"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 5
        attempt=$((attempt + 1))
    done
    echo -e "${RED}✗ $service failed to start${NC}"
    return 1
}

# Create remote directory
echo "Creating remote directory..."
ssh ${REMOTE_USER}@${DROPLET_IP} "mkdir -p ${REMOTE_DIR}"
check_status "Created remote directory"

# Copy configuration files
echo "Copying configuration files..."
scp docker-compose.yml ${REMOTE_USER}@${DROPLET_IP}:${REMOTE_DIR}/
check_status "Copied docker-compose.yml"

scp -r prometheus ${REMOTE_USER}@${DROPLET_IP}:${REMOTE_DIR}/
check_status "Copied prometheus configuration"

scp -r alertmanager ${REMOTE_USER}@${DROPLET_IP}:${REMOTE_DIR}/
check_status "Copied alertmanager configuration"

scp -r blackbox ${REMOTE_USER}@${DROPLET_IP}:${REMOTE_DIR}/
check_status "Copied blackbox configuration"

scp -r grafana ${REMOTE_USER}@${DROPLET_IP}:${REMOTE_DIR}/
check_status "Copied grafana configuration"

# Stop existing containers and start new ones
echo "Deploying services..."
ssh ${REMOTE_USER}@${DROPLET_IP} "cd ${REMOTE_DIR} && docker-compose down && docker-compose up -d"
check_status "Started services"

# Wait for services to be ready
wait_for_service "Grafana" "3001"
wait_for_service "Prometheus" "9090"
wait_for_service "Alertmanager" "9093"
wait_for_service "Node Exporter" "9100"
wait_for_service "Blackbox Exporter" "9115"

echo -e "${GREEN}Deployment complete!${NC}"
echo "Services are available at:"
echo "Grafana: http://${DROPLET_IP}:3001"
echo "Prometheus: http://${DROPLET_IP}:9090"
echo "Alertmanager: http://${DROPLET_IP}:9093"
echo "Node Exporter: http://${DROPLET_IP}:9100"
echo "Blackbox Exporter: http://${DROPLET_IP}:9115" 