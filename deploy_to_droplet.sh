#!/bin/bash

# Exit on error
set -e

echo "Deploying monitoring stack to DigitalOcean droplet..."

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p /opt/monitoring/{alertmanager,prometheus,grafana,blackbox}
mkdir -p /opt/monitoring/grafana/provisioning/datasources

# Set up firewall
echo "Setting up firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 9093/tcp  # Alertmanager
ufw allow 9090/tcp  # Prometheus
ufw allow 3001/tcp  # Grafana
ufw allow 9115/tcp  # Blackbox exporter
ufw allow 9100/tcp  # Node exporter
ufw --force enable

# Create docker-compose.yml
echo "Creating docker-compose.yml..."
cat > /opt/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "138.68.249.92:9090:9090"
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    restart: unless-stopped
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "138.68.249.92:9093:9093"
    volumes:
      - ./alertmanager:/etc/alertmanager
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    restart: unless-stopped
    networks:
      - monitoring

  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    container_name: blackbox-exporter
    ports:
      - "138.68.249.92:9115:9115"
    volumes:
      - ./blackbox:/config
    command:
      - '--config.file=/config/blackbox.yml'
    restart: unless-stopped
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "138.68.249.92:9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "138.68.249.92:3001:3000"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_HTTP_ADDR=0.0.0.0
      - GF_SERVER_ROOT_URL=http://138.68.249.92:3001
    restart: unless-stopped
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
EOF

# Create Grafana configuration
echo "Creating Grafana configuration..."
cat > /opt/monitoring/grafana/grafana.ini << 'EOF'
[server]
http_port = 3000
domain = 138.68.249.92
root_url = http://138.68.249.92:3001/
serve_from_sub_path = false

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = false

[paths]
provisioning = /etc/grafana/provisioning

[users]
default_theme = dark
EOF

# Create Prometheus datasource configuration
echo "Creating Prometheus datasource configuration..."
cat > /opt/monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
# config file version
apiVersion: 1

# list of datasources to insert/update
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://138.68.249.92:9090
    isDefault: true
    jsonData:
      httpMethod: GET
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 2.45.0
      cacheLevel: None
      incrementalQueryOverlapWindow: 10m
      queryTimeout: 30s
    editable: true
    uid: PBFA97CFB590B2093
EOF

# Create basic configuration files
echo "Creating basic configuration files..."

# Prometheus configuration
mkdir -p /opt/monitoring/prometheus
cat > /opt/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['138.68.249.92:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'blackbox'
    static_configs:
      - targets: ['blackbox-exporter:9115']
EOF

# Alertmanager configuration
mkdir -p /opt/monitoring/alertmanager
cat > /opt/monitoring/alertmanager/alertmanager.yml << 'EOF'
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'mattermost'

receivers:
- name: 'mattermost'
  webhook_configs:
  - url: 'http://138.68.249.92:8065/hooks/ou4n5jny43fp5mttzmdokpuh1a'
EOF

# Blackbox configuration
mkdir -p /opt/monitoring/blackbox
cat > /opt/monitoring/blackbox/blackbox.yml << 'EOF'
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      method: GET
      preferred_ip_protocol: ip4
      tls_config:
        insecure_skip_verify: true
EOF

# Start services
echo "Starting monitoring services..."
cd /opt/monitoring
docker-compose up -d

echo "Deployment complete!"
echo "Your monitoring stack is now running on this server."
echo "Alertmanager: http://138.68.249.92:9093"
echo "Prometheus: http://138.68.249.92:9090"
echo "Grafana: http://138.68.249.92:3001" 