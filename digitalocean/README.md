# Deploying Monitoring Stack to DigitalOcean

This guide will help you deploy your monitoring stack (Prometheus, Grafana, Alertmanager, etc.) to a DigitalOcean Droplet.

## Prerequisites

1. A DigitalOcean account
2. Basic knowledge of SSH and command line
3. Your Mattermost webhook URL

## Step 1: Create a DigitalOcean Droplet

1. Log in to your DigitalOcean account
2. Click "Create" and select "Droplets"
3. Choose an image: Ubuntu 22.04 LTS
4. Choose a plan: Basic (2GB RAM / 1 CPU is sufficient)
5. Choose a datacenter region close to your users
6. Add your SSH keys for secure access
7. Click "Create Droplet"

## Step 2: Prepare Your Local Files

1. Update the `alertmanager.yml` file with your Mattermost webhook URL
2. Copy your existing alert rules to the `prometheus/rules` directory
3. Copy your existing Grafana dashboards to the `grafana/provisioning` directory

## Step 3: Deploy to DigitalOcean

1. SSH into your Droplet:
   ```bash
   ssh root@your_droplet_ip
   ```

2. Create the necessary directories:
   ```bash
   mkdir -p /opt/monitoring
   ```

3. Copy your configuration files to the server:
   ```bash
   # From your local machine
   scp -r digitalocean/* root@your_droplet_ip:/opt/monitoring/
   ```

4. Make the deployment script executable:
   ```bash
   # On the Droplet
   chmod +x /opt/monitoring/deploy.sh
   ```

5. Run the deployment script:
   ```bash
   # On the Droplet
   cd /opt/monitoring
   ./deploy.sh
   ```

## Step 4: Verify Deployment

1. Check if all containers are running:
   ```bash
   docker-compose ps
   ```

2. Access your services:
   - Alertmanager: http://your_droplet_ip:9093
   - Prometheus: http://your_droplet_ip:9090
   - Grafana: http://your_droplet_ip:3001 (username: admin, password: admin)

## Step 5: Update Mattermost Configuration

1. Update your Mattermost webhook URL in the Alertmanager configuration
2. Restart the Alertmanager service:
   ```bash
   docker-compose restart alertmanager
   ```

## Troubleshooting

- Check container logs: `docker-compose logs [service_name]`
- Restart services: `docker-compose restart [service_name]`
- Check firewall settings: `ufw status`

## Security Considerations

- Change default passwords for Grafana
- Consider setting up HTTPS with Let's Encrypt
- Regularly update your containers: `docker-compose pull && docker-compose up -d`

## Development URLs 🔗

### Mattermost Channel
- AlertManager Dev Channel: http://138.68.249.92:8065/solheim-tech/channels/alertmanager-dev

### Webhooks
- AlertManager Webhook: http://138.68.249.92:8065/hooks/ou4n5jny43fp5mttzmdokpuh1a 