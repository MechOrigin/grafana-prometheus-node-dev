#!/bin/bash

# Configuration
SERVER="grafana-prometheus"
DEPLOY_DIR="/opt/grafana-prometheus-node-dev"
COMPOSE_FILE="docker-compose.yml"
BACKUP_DIR="${DEPLOY_DIR}/backups"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to show script usage
usage() {
    echo -e "${YELLOW}Usage: $0 [sync|restart|deploy|cleanup|backup]${NC}"
    echo "  sync    - Only sync files to server"
    echo "  restart - Only restart Docker services"
    echo "  deploy  - Sync files and restart services"
    echo "  cleanup - Clean up old Docker images and volumes"
    echo "  backup  - Create backup of configuration files"
    exit 1
}

# Function to sync files
sync_files() {
    echo -e "${GREEN}Syncing files to server...${NC}"
    rsync -avz --exclude 'node_modules' \
               --exclude '.git' \
               --exclude 'dist' \
               --exclude 'build' \
               --exclude 'coverage' \
               --exclude 'tmp' \
               --exclude 'backups' \
               ./ $SERVER:$DEPLOY_DIR/
}

# Function to restart services
restart_services() {
    echo -e "${GREEN}Restarting Docker services...${NC}"
    ssh $SERVER "cd $DEPLOY_DIR && docker-compose down && docker-compose up -d"
}

# Function to clean up Docker resources
cleanup_docker() {
    echo -e "${GREEN}Cleaning up Docker resources...${NC}"
    ssh $SERVER "cd $DEPLOY_DIR && \
        docker-compose down && \
        docker system prune -af --volumes && \
        docker builder prune -af"
}

# Function to create backup
create_backup() {
    echo -e "${GREEN}Creating backup...${NC}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="config_backup_${timestamp}.tar.gz"
    
    ssh $SERVER "cd $DEPLOY_DIR && \
        mkdir -p $BACKUP_DIR && \
        tar -czf $BACKUP_DIR/$backup_file \
            alertmanager/alertmanager.yml \
            prometheus/prometheus.yml \
            grafana/provisioning \
            blackbox/blackbox.yml \
            docker-compose.yml"
    
    echo -e "${GREEN}Backup created: $backup_file${NC}"
}

# Check if we have an argument
if [ $# -eq 0 ]; then
    usage
fi

# Process based on argument
case "$1" in
    sync)
        sync_files
        ;;
    restart)
        restart_services
        ;;
    deploy)
        sync_files
        restart_services
        ;;
    cleanup)
        cleanup_docker
        ;;
    backup)
        create_backup
        ;;
    *)
        usage
        ;;
esac

echo -e "${GREEN}Operation completed successfully!${NC}"
