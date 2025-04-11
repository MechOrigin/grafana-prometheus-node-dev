#!/bin/bash

# Exit on error
set -e

echo "Fixing firewall configuration..."

# Reset UFW
ufw --force reset

# Allow SSH first (important!)
ufw allow 22/tcp

# Allow monitoring ports
ufw allow 3001/tcp  # Grafana
ufw allow 9090/tcp  # Prometheus
ufw allow 9093/tcp  # Alertmanager
ufw allow 9115/tcp  # Blackbox exporter
ufw allow 9100/tcp  # Node exporter

# Enable firewall
ufw --force enable

# Show status
ufw status

echo "Firewall configuration complete!" 