# Server Monitoring Solution

A comprehensive server monitoring solution using Grafana, Prometheus, and Node Exporter. This setup provides real-time monitoring of server resources, website performance, and SSL certificate status.

## Features

- Real-time server resource monitoring (CPU, Memory, Disk, Network)
- Website performance monitoring
- SSL certificate monitoring and alerts
- System metrics dashboard
- Custom alerting rules
- Docker-based deployment

## Quick Start (For Beginners)

1. First, make sure you have Docker and Docker Compose installed on your computer.

2. Open your terminal and run these commands:
```bash
# Clone this repository
git clone https://github.com/yourusername/grafana-prometheus-node-dev.git

# Go into the project folder
cd grafana-prometheus-node-dev

# Start all the services
docker-compose up -d
```

3. Once everything is running, you can access:
   - Grafana dashboard: http://localhost:3001 (Username: admin, Password: admin)
   - Prometheus: http://localhost:9090
   - Alertmanager: http://localhost:9093
   - Node Exporter: http://localhost:9100

That's it! You're now monitoring your server! 🎉

## Detailed Setup

### Prerequisites

- Docker
- Docker Compose
- Git

### Components

1. **Grafana** (Port: 3001)
   - Web-based visualization platform
   - Pre-configured dashboards
   - Custom alerting rules

2. **Prometheus** (Port: 9090)
   - Metrics collection and storage
   - Query language for data analysis
   - Alert rule evaluation

3. **Alertmanager** (Port: 9093)
   - Handles alert notifications
   - Alert routing and grouping
   - Notification templates

4. **Node Exporter** (Port: 9100)
   - System metrics collection
   - Hardware and OS metrics
   - Performance data

### Configuration Files

- `docker-compose.yml`: Main service configuration
- `prometheus/prometheus.yml`: Prometheus configuration
- `alertmanager/alertmanager.yml`: Alertmanager configuration
- `grafana/provisioning/`: Grafana dashboards and data sources

### Default Credentials

- Grafana:
  - Username: admin
  - Password: admin

## Monitoring Features

### Server Metrics
- CPU usage and load
- Memory utilization
- Disk space and I/O
- Network traffic
- System uptime

### Website Monitoring
- Response times
- HTTP status codes
- SSL certificate status
- DNS resolution
- Website availability

### Alerts
- High CPU/Memory usage
- Disk space warnings
- Website downtime
- SSL certificate expiration
- DNS resolution failures

## Maintenance

### Starting Services
```bash
docker-compose up -d
```

### Stopping Services
```bash
docker-compose down
```

### Viewing Logs
```bash
docker-compose logs -f
```

### Restarting Services
```bash
docker-compose restart
```

## Troubleshooting

1. If you can't access Grafana:
   - Check if the container is running: `docker-compose ps`
   - View Grafana logs: `docker-compose logs grafana`

2. If metrics aren't showing:
   - Verify Prometheus is running: `docker-compose ps prometheus`
   - Check Node Exporter: `docker-compose ps node-exporter`

3. If alerts aren't working:
   - Check Alertmanager logs: `docker-compose logs alertmanager`
   - Verify Prometheus rules: `docker-compose logs prometheus`

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 