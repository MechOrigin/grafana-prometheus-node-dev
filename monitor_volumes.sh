#!/bin/bash

# Exit on error
set -e

# Log file
LOG_FILE="/var/log/volume-monitor.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if a volume is read-only
check_volume() {
    local container=$1
    local path=$2
    local test_file="$path/volume_check_$(date +%s)"
    
    docker exec "$container" touch "$test_file" 2>/dev/null
    if [ $? -ne 0 ]; then
        log_message "WARNING: Volume in $container at $path appears to be read-only"
        return 1
    fi
    docker exec "$container" rm "$test_file" 2>/dev/null
    return 0
}

# Function to handle read-only volume
handle_readonly() {
    local container=$1
    local volume=$2
    
    log_message "Attempting to recover $container with read-only volume $volume"
    
    # Stop the container
    log_message "Stopping container $container"
    docker stop "$container"
    
    # Wait a moment for filesystem operations to complete
    sleep 5
    
    # Start the container
    log_message "Starting container $container"
    docker start "$container"
    
    # Check if the issue is resolved
    sleep 10
    if check_volume "$container" "$volume"; then
        log_message "Successfully recovered $container"
        return 0
    else
        log_message "ERROR: Failed to recover $container"
        # Send alert via Alertmanager
        curl -X POST -H "Content-Type: application/json" -d '{
            "labels": {
                "alertname": "VolumeReadOnly",
                "severity": "critical",
                "container": "'"$container"'",
                "volume": "'"$volume"'"
            },
            "annotations": {
                "summary": "Volume became read-only",
                "description": "The volume '"$volume"' in container '"$container"' became read-only and automatic recovery failed."
            }
        }' http://localhost:9093/api/v1/alerts
        return 1
    fi
}

# Main monitoring loop
while true; do
    # Check Prometheus volume
    if ! check_volume "prometheus" "/prometheus"; then
        handle_readonly "prometheus" "/prometheus"
    fi
    
    # Check Grafana volume
    if ! check_volume "grafana" "/var/lib/grafana"; then
        handle_readonly "grafana" "/var/lib/grafana"
    fi
    
    # Check Alertmanager volume
    if ! check_volume "alertmanager" "/alertmanager"; then
        handle_readonly "alertmanager" "/alertmanager"
    fi
    
    # Wait before next check
    sleep 300  # Check every 5 minutes
done 