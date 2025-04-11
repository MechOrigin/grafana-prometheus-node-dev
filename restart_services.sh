#!/bin/bash

# Exit on error
set -e

echo "Restarting Docker services and containers..."

# Stop all containers
echo "Stopping all containers..."
docker-compose down

# Restart Docker service
echo "Restarting Docker service..."
systemctl restart docker

# Start containers
echo "Starting containers..."
docker-compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 10

# Check container status
echo "Container status:"
docker ps

# Check logs
echo "Grafana logs:"
docker logs grafana

echo "Prometheus logs:"
docker logs prometheus

echo "Alertmanager logs:"
docker logs alertmanager

echo "Restart complete!" 