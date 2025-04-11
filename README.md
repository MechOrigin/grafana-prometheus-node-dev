# Server Monitoring Solution

A comprehensive server monitoring solution using Grafana, Prometheus, and Node Exporter. This setup provides real-time monitoring of server resources, website performance, and SSL certificate status.

## Features

- Real-time server resource monitoring (CPU, Memory, Disk, Network)
- Website performance monitoring with Blackbox Exporter
- SSL certificate monitoring and alerts
- System metrics dashboard
- Custom alerting rules
- Docker-based deployment

## Quick Start (Super Easy Guide!)

Hey there! 👋 Let's get your monitoring system up and running. It's like setting up a bunch of helpful robots to watch over your computer! 

### Step 1: Get the Tools
First, you'll need to install two things on your computer:
1. Docker (it's like a special box that runs our monitoring tools)
2. Docker Compose (it helps us run all our tools together)

You can download these from [Docker's website](https://www.docker.com/products/docker-desktop/).

### Step 2: Get Our Code
Open your computer's terminal (it's like a special text box where we type commands) and type these commands one by one:

```bash
# This downloads our special monitoring code
git clone https://github.com/yourusername/grafana-prometheus-node-dev.git

# This moves you into the folder with our code
cd grafana-prometheus-node-dev
```

### Step 3: Start Everything Up!
Now, let's start all our monitoring tools with one simple command:

```bash
docker-compose up -d
```

That's it! 🎉 All your monitoring tools are now running! Here's what you can look at:

- Grafana Dashboard (like a control panel): http://138.68.249.92:3001
  - Username: admin
  - Password: admin
- Prometheus (data collector): http://138.68.249.92:9090
- Node Exporter (computer monitor): http://138.68.249.92:9100
- Blackbox Exporter (website checker): http://138.68.249.92:9115

## Detailed Setup

### Prerequisites

- Docker
- Docker Compose
- Git

### Components

1. **Grafana** (Port: 3001)
   - Beautiful dashboards to see all your data
   - Ready-to-use monitoring panels
   - Easy-to-set-up alerts

2. **Prometheus** (Port: 9090)
   - Collects and stores all your monitoring data
   - Powerful search tools for your data
   - Handles alert rules

3. **Node Exporter** (Port: 9100)
   - Watches your computer's health
   - Tracks CPU, memory, and disk usage
   - Monitors network activity

4. **Blackbox Exporter** (Port: 9115)
   - Checks if websites are working
   - Monitors SSL certificates
   - Tests website response times

### Configuration Files

- `docker-compose.yml`: Tells Docker how to run everything
- `prometheus/prometheus.yml`: Sets up what Prometheus should watch
- `alertmanager/alertmanager.yml`: Controls how alerts are sent
- `grafana/provisioning/`: Contains ready-to-use dashboards
- `blackbox/blackbox.yml`: Configures website monitoring

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

### Alerting
- Alerts are configured to be sent to MatterMost
- Development Environment Webhook URL: http://138.68.249.92:8065/hooks/ou4n5jny43fp5mttzmdokpuh1a
- To set up MatterMost alerts in production:
  1. Create a webhook in your MatterMost server
  2. Copy the webhook URL
  3. Update the `alertmanager/alertmanager.yml` file with your webhook URL
  4. Restart the Alertmanager service: `docker-compose restart alertmanager`

Note: For production environments, never commit your actual webhook URL to version control. Use environment variables or a secure configuration management system.

## Testing Alerts

Want to make sure your alerts are working? It's super easy! 🚀

### Step 1: Check Alertmanager
First, make sure Alertmanager is running:
```bash
docker-compose ps alertmanager
```
You should see it running happily! 

### Step 2: Watch for Test Alerts
We've set up a special test alert that runs every 5 minutes. It's like a friendly robot saying "Hello!" to make sure everything is working. You'll see it in your Mattermost channel!

### Step 3: What Alerts Will You See?
You'll get alerts for lots of important things:
- 🖥️ When your computer is working too hard (high CPU usage)
- 💾 When your computer is running out of space (high disk usage)
- 🌐 When websites aren't working properly
- 🔒 When SSL certificates need attention
- ⚡ When anything else important happens!

### Step 4: Check Your Mattermost Channel
1. Open Mattermost
2. Look for the channel where alerts are sent
3. You should see messages that look like this:
   ```
   🚨 Alert: TestAlert
   Severity: warning
   Description: This is a test alert that fires every 5 minutes
   ```

### Troubleshooting Alerts
If you don't see alerts:
1. Make sure Mattermost is running
2. Check if the webhook URL is correct in `alertmanager/alertmanager.yml`
3. Try restarting Alertmanager:
   ```bash
   docker-compose restart alertmanager
   ```

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
   - View Grafana logs: `