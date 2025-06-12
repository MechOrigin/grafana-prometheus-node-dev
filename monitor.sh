#!/bin/bash

# Configuration
SERVER="grafana-prometheus"
DEPLOY_DIR="/opt/grafana-prometheus-node-dev"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to check disk space
check_disk_space() {
    echo -e "${YELLOW}Checking disk space...${NC}"
    ssh $SERVER "df -h / && echo -e '\nLargest directories:' && du -h $DEPLOY_DIR --max-depth=1 | sort -hr | head -n 5"
}

# Function to check Docker services
check_services() {
    echo -e "${YELLOW}Checking Docker services...${NC}"
    ssh $SERVER "cd $DEPLOY_DIR && docker-compose ps"
}

# Function to check Docker logs
check_logs() {
    local service=$1
    if [ -z "$service" ]; then
        echo -e "${RED}Please specify a service name${NC}"
        return 1
    fi
    echo -e "${YELLOW}Checking logs for $service...${NC}"
    ssh $SERVER "cd $DEPLOY_DIR && docker-compose logs --tail=50 $service"
}

# Function to check service health
check_health() {
    echo -e "${YELLOW}Checking service health...${NC}"
    
    # Check Prometheus
    echo -e "\n${GREEN}Checking Prometheus...${NC}"
    curl -s "http://$SERVER:9090/-/healthy" || echo "Prometheus health check failed"
    
    # Check Grafana
    echo -e "\n${GREEN}Checking Grafana...${NC}"
    curl -s "http://$SERVER:3001/api/health" || echo "Grafana health check failed"
    
    # Check Alertmanager
    echo -e "\n${GREEN}Checking Alertmanager...${NC}"
    curl -s "http://$SERVER:9093/-/healthy" || echo "Alertmanager health check failed"
}

# Function to check resource usage
check_resources() {
    echo -e "${YELLOW}Checking resource usage...${NC}"
    ssh $SERVER "cd $DEPLOY_DIR && \
        echo -e '\n${GREEN}Memory Usage:${NC}' && \
        docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' && \
        echo -e '\n${GREEN}Container Disk Usage:${NC}' && \
        docker system df"
}

# Function to show script usage
usage() {
    echo -e "${YELLOW}Usage: $0 [disk|services|logs <service_name>|health|resources]${NC}"
    echo "  disk      - Check disk space and largest directories"
    echo "  services  - Check status of all services"
    echo "  logs      - Show logs for a specific service"
    echo "  health    - Check health endpoints of services"
    echo "  resources - Check container resource usage"
    exit 1
}

# Check if we have an argument
if [ $# -eq 0 ]; then
    usage
fi

# Process based on argument
case "$1" in
    disk)
        check_disk_space
        ;;
    services)
        check_services
        ;;
    logs)
        if [ -z "$2" ]; then
            echo -e "${RED}Please specify a service name${NC}"
            usage
        fi
        check_logs "$2"
        ;;
    health)
        check_health
        ;;
    resources)
        check_resources
        ;;
    *)
        usage
        ;;
esac 