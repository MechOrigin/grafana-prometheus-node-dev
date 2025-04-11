from typing import Dict, Any
from ..config import load_config

def transform_alert(alert: Dict[str, Any]) -> Dict[str, Any]:
    """Transform Alertmanager alert to Mattermost message format."""
    config = load_config()
    templates = config['templates']
    
    # Get alert severity
    severity = alert.get('labels', {}).get('severity', 'info').lower()
    
    # Select template based on severity
    template = templates.get(severity, templates['info'])
    
    # Extract alert details
    status = alert.get('status', 'unknown')
    labels = alert.get('labels', {})
    annotations = alert.get('annotations', {})
    
    # Build message text
    message = template['format'].format(
        icon=template['icon'],
        title=template['title'],
        alertname=labels.get('alertname', 'Unknown Alert'),
        status=status,
        service=labels.get('service', 'Unknown Service'),
        instance=labels.get('instance', 'Unknown Instance'),
        summary=annotations.get('summary', 'No summary provided'),
        description=annotations.get('description', 'No description provided'),
        runbook=annotations.get('runbook', 'No runbook provided')
    )
    
    # Create Mattermost payload
    mattermost_payload = {
        "text": message,
        "username": "Alertmanager",
        "icon_emoji": ":bell:",
        "props": {
            "alert_data": {
                "severity": severity,
                "status": status,
                "labels": labels,
                "annotations": annotations
            }
        }
    }
    
    return mattermost_payload 