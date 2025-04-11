#!/bin/bash

# Exit on error
set -e

echo "Checking Docker containers and network configuration..."

# Check Docker service status
echo "Docker service status:"
systemctl status docker

# List running containers
echo "Running Docker containers:"
docker ps

# Check container logs
echo "Grafana logs:"
docker logs grafana

echo "Prometheus logs:"
docker logs prometheus

echo "Alertmanager logs:"
docker logs alertmanager

# Check network configuration
echo "Network interfaces:"
ip addr show

# Check listening ports
echo "Listening ports:"
netstat -tulpn

echo "Check complete!" 