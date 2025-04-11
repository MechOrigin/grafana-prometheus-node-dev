# 🔔 Alert Bridge: Alertmanager to Mattermost

This is a friendly bridge that helps Alertmanager talk to Mattermost! Think of it as a translator that takes alerts from Alertmanager and makes them look nice in Mattermost.

## 🎯 What Does It Do?

1. Gets alerts from Alertmanager
2. Makes them look pretty
3. Sends them to Mattermost
4. Tells you if everything worked!

## 🚀 How to Start It

The alert bridge is part of our monitoring system. It starts automatically with everything else!

To start everything:
```bash
cd /root/grafana-prometheus-node-dev
docker-compose up -d
```

## 🔍 How to Check If It's Working

### 1. Check if it's running:
```bash
docker-compose ps
```
Look for `alert-bridge` - it should say "Up" or "Running"!

### 2. Look at what it's doing:
```bash
docker-compose logs alert-bridge
```
You should see messages about receiving and sending alerts.

### 3. Check Mattermost:
Go to your Mattermost channel - you should see nice alert messages appearing!

## 🎨 Alert Types

We have different styles for different types of alerts:

- 🔴 **Critical Alerts**: Big red circle, lots of details
- ⚠️ **Warning Alerts**: Yellow warning sign
- ℹ️ **Info Alerts**: Blue info sign

## 🆘 Common Problems and Solutions

1. **No alerts in Mattermost?**
   - Check if alert-bridge is running
   - Look at the logs for errors
   - Make sure Mattermost is running

2. **Alert-bridge won't start?**
   - Make sure nothing else is using port 9095
   - Check if all files are in the right place
   - Look at the logs for error messages

3. **Weird-looking alerts?**
   - Check the templates in `config/config.yml`
   - Make sure the alert has all needed information

## 📞 Need Help?

If something's not working:
1. Check the logs: `docker-compose logs alert-bridge`
2. Make sure all services are running: `docker-compose ps`
3. Ask for help from your team!

## 🔧 Configuration

The bridge uses these files:
- `config/config.yml`: Message templates and settings
- `docker-compose.yml`: Container settings
- `alertmanager/alertmanager.yml`: Alert rules

Remember: Don't change these files unless you know what you're doing! 😊 