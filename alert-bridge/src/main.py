from flask import Flask, request, jsonify
import requests
import logging
from datetime import datetime
from typing import Dict, Any
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s %(name)s %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration
def get_webhook_url():
    """Get webhook URL from secrets or environment variable"""
    secret_path = '/run/secrets/mattermost_webhook_url'
    if os.path.exists(secret_path):
        with open(secret_path, 'r') as f:
            return f.read().strip()
    return os.environ.get('MATTERMOST_WEBHOOK_URL')

MATTERMOST_WEBHOOK_URL = get_webhook_url()
MAX_RETRIES = int(os.environ.get('MAX_RETRIES', '3'))
RETRY_BACKOFF = int(os.environ.get('RETRY_BACKOFF', '2'))
PORT = int(os.environ.get('PORT', '10000'))

def format_alert_message(alert_data):
    """Format alert data into a Mattermost message."""
    logger.info(f"Received alert data: {alert_data}")
    
    messages = []
    alerts = alert_data.get('alerts', [])
    
    for alert in alerts:
        status = alert.get('status', 'unknown')
        labels = alert.get('labels', {})
        annotations = alert.get('annotations', {})
        
        if status == 'firing':
            header = "🔥 Alerts Firing"
        else:
            header = "✅ Alerts Resolved"
        
        message = (
            f"{header}\n"
            f"Alert: {labels.get('alertname', 'Unknown')}\n"
            f"Severity: {labels.get('severity', 'unknown')}\n"
            f"Description: {annotations.get('description', 'No description')}\n\n"
            f"Started: {alert.get('startsAt', 'Unknown').replace('T', ' ').replace('Z', ' UTC')}"
        )
        messages.append(message)
    
    return {
        "text": "\n\n".join(messages)
    }

def send_to_mattermost(message: Dict[str, str], retries: int = 0) -> bool:
    """Send message to Mattermost with retry logic"""
    try:
        logger.debug(f"Sending message to Mattermost (attempt {retries + 1}): {message}")
        logger.debug(f"Using webhook URL: {MATTERMOST_WEBHOOK_URL}")
        response = requests.post(MATTERMOST_WEBHOOK_URL, json=message)
        logger.debug(f"Mattermost response status: {response.status_code}")
        logger.debug(f"Mattermost response content: {response.text}")
        response.raise_for_status()
        logger.info("Successfully sent alert to Mattermost")
        return True
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to send alert to Mattermost: {e}")
        logger.error(f"Request details - URL: {MATTERMOST_WEBHOOK_URL}, Message: {message}")
        if retries < MAX_RETRIES:
            import time
            time.sleep(RETRY_BACKOFF ** retries)
            return send_to_mattermost(message, retries + 1)
        return False

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "webhook_url": MATTERMOST_WEBHOOK_URL,
        "config": {
            "max_retries": MAX_RETRIES,
            "retry_backoff": RETRY_BACKOFF,
            "port": PORT
        }
    })

@app.route('/api/v1/alerts', methods=['POST'])
def receive_alert():
    """Receive alerts from Alertmanager"""
    logger.debug(f"Received request: {request.headers}")
    
    if not request.is_json:
        logger.error("Request Content-Type is not application/json")
        return jsonify({"error": "Content-Type must be application/json"}), 400
    
    try:
        alert_data = request.get_json()
        logger.info(f"Received alert: {alert_data}")
        
        # Format message for Mattermost
        message = format_alert_message(alert_data)
        
        # Send to Mattermost
        if send_to_mattermost(message):
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"error": "Failed to send to Mattermost after retries"}), 500
            
    except Exception as e:
        logger.exception("Error processing alert")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    if not MATTERMOST_WEBHOOK_URL:
        raise ValueError("MATTERMOST_WEBHOOK_URL environment variable must be set")
    
    logger.info(f"Starting alert-bridge with webhook URL: {MATTERMOST_WEBHOOK_URL}")
    app.run(host='0.0.0.0', port=PORT) 