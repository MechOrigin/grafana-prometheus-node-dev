# 🎯 Grafana-Prometheus-Node Development Environment

A friendly monitoring system that watches over your servers and tells you when something needs attention!

## 🌟 What's Inside?

Our monitoring system has these cool parts:

1. 📊 **Grafana** (port 3001)
   - Makes pretty graphs and dashboards
   - Shows you what's happening on your servers
   - Helps you spot problems quickly

2. 🔍 **Prometheus** (port 9090)
   - Collects information about your servers
   - Keeps track of everything
   - Notices when something's wrong

3. 🚨 **Alertmanager** (port 9093)
   - Watches for problems
   - Sends alerts when something needs attention
   - Groups similar alerts together

4. 🔔 **Alert Bridge** (port 9095)
   - Our friendly translator!
   - Takes alerts from Alertmanager
   - Makes them look nice in Mattermost
   - Check its own README in `alert-bridge/` folder!

5. 📡 **Node Exporter** (port 9100)
   - Watches your server
   - Reports CPU, memory, and disk usage
   - Tells Prometheus how the server is doing

6. 🌐 **Blackbox Exporter** (port 9115)
   - Checks if websites are working
   - Makes sure services are responding
   - Tells you if something's down

## 🚀 How to Start Everything

1. Go to the right folder:
   ```bash
   cd /root/grafana-prometheus-node-dev
   ```

2. Start all services:
   ```bash
   docker-compose up -d
   ```

3. Check if everything's running:
   ```bash
   docker-compose ps
   ```

## 🔍 How to Check If It's Working

1. **Check Grafana**
   - Open http://167.71.155.226:3001 in your browser
   - Log in with your username and password
   - You should see dashboards!

2. **Check Alerts**
   - Look in your Mattermost channel
   - You should see nice alert messages
   - They should have different colors for different alert types

3. **Check the Logs**
   ```bash
   # Check all logs:
   docker-compose logs

   # Or check just one service:
   docker-compose logs grafana
   docker-compose logs alertmanager
   docker-compose logs alert-bridge
   ```

## 🆘 Need Help?

If something's not working:

1. Check if all services are running:
   ```bash
   docker-compose ps
   ```

2. Look at the logs for errors:
   ```bash
   docker-compose logs
   ```

3. Make sure you can reach:
   - Grafana: http://167.71.155.226:3001
   - Mattermost: http://138.68.249.92:8065

4. Check the specific service's README:
   - Alert Bridge: Look in `alert-bridge/README.md`

## 📁 Important Files

- `docker-compose.yml`: Controls all services
- `alertmanager/alertmanager.yml`: Alert settings
- `prometheus/prometheus.yml`: Monitoring settings
- `grafana/`: Dashboard settings
- `alert-bridge/`: Our alert translator service

## 🔐 Important Information

- Grafana runs on port 3001
- Mattermost is at 138.68.249.92:8065
- Alert Bridge helps Alertmanager talk to Mattermost
- Everything runs in Docker containers
- All data is saved even if you restart

Remember: Be careful when changing settings! If you're not sure, ask for help! 😊