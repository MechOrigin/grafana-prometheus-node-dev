from flask import Flask, request, jsonify
import requests
import logging
from datetime import datetime
from typing import Dict, Any
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
MATTERMOST_WEBHOOK_URL = os.environ.get('MATTERMOST_WEBHOOK_URL')
MAX_RETRIES = int(os.environ.get('MAX_RETRIES', '3'))
RETRY_BACKOFF = int(os.environ.get('RETRY_BACKOFF', '2'))

def format_alert_message(alert_data: Dict[str, Any]) -> Dict[str, str]:
    """Format Alertmanager alert into Mattermost message"""
    alerts = alert_data.get('alerts', [])
    status = alert_data.get('status', 'unknown')
    
    # Group alerts by status
    firing = [a for a in alerts if a.get('status') == 'firing']
    resolved = [a for a in alerts if a.get('status') == 'resolved']
    
    message_parts = []
    
    # Format firing alerts
    if firing:
        message_parts.append("🔥 **Alerts Firing**")
        for alert in firing:
            message_parts.extend([
                f"**Alert:** {alert.get('labels', {}).get('alertname')}",
                f"**Severity:** {alert.get('labels', {}).get('severity', 'unknown')}",
                f"**Description:** {alert.get('annotations', {}).get('description')}",
                f"**Started:** {datetime.fromisoformat(alert.get('startsAt', '').replace('Z', '+00:00')).strftime('%Y-%m-%d %H:%M:%S UTC')}",
                "---"
            ])
    
    # Format resolved alerts
    if resolved:
        message_parts.append("✅ **Alerts Resolved**")
        for alert in resolved:
            message_parts.extend([
                f"**Alert:** {alert.get('labels', {}).get('alertname')}",
                f"**Severity:** {alert.get('labels', {}).get('severity', 'unknown')}",
                f"**Description:** {alert.get('annotations', {}).get('description')}",
                f"**Resolved:** {datetime.fromisoformat(alert.get('endsAt', '').replace('Z', '+00:00')).strftime('%Y-%m-%d %H:%M:%S UTC')}",
                "---"
            ])
    
    return {
        "text": "\n".join(message_parts),
        "username": "Alertmanager",
        "icon_emoji": ":warning:"
    }

def send_to_mattermost(message: Dict[str, str], retries: int = 0) -> bool:
    """Send message to Mattermost with retry logic"""
    try:
        response = requests.post(MATTERMOST_WEBHOOK_URL, json=message)
        response.raise_for_status()
        logger.info("Successfully sent alert to Mattermost")
        return True
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to send alert to Mattermost: {e}")
        if retries < MAX_RETRIES:
            import time
            time.sleep(RETRY_BACKOFF ** retries)
            return send_to_mattermost(message, retries + 1)
        return False

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy"})

@app.route('/api/v1/alerts', methods=['POST'])
def receive_alert():
    """Receive alerts from Alertmanager"""
    if not request.is_json:
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
    
    app.run(host='0.0.0.0', port=9094) 