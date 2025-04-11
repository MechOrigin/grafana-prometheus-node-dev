from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
import requests
import logging
import json
from typing import Dict, Any
import time
from .utils.transformer import transform_alert
from .utils.logger import setup_logger
from .config import load_config

# Initialize FastAPI app
app = FastAPI(title="Alertmanager to Mattermost Bridge")

# Setup logging
logger = setup_logger()

# Load configuration
config = load_config()

# Prometheus metrics
ALERT_COUNTER = Counter('alert_bridge_alerts_total', 'Total number of alerts received', ['severity'])
ALERT_LATENCY = Histogram('alert_bridge_latency_seconds', 'Alert processing latency in seconds')
MATTERMOST_ERRORS = Counter('alert_bridge_mattermost_errors_total', 'Total number of Mattermost delivery errors')

@app.post("/api/v1/alerts")
async def receive_alert(request: Request):
    try:
        alert_data = await request.json()
        logger.info("Received alert", extra={"alert_data": alert_data})
        
        with ALERT_LATENCY.time():
            # Handle both list and dictionary inputs
            alerts = alert_data if isinstance(alert_data, list) else alert_data.get('alerts', [])
            
            for alert in alerts:
                severity = alert.get('labels', {}).get('severity', 'unknown')
                ALERT_COUNTER.labels(severity=severity).inc()
                
                # Transform alert to Mattermost format
                mattermost_payload = transform_alert(alert)
                
                # Send to Mattermost
                response = requests.post(
                    config['mattermost']['webhook_url'],
                    json=mattermost_payload,
                    timeout=5
                )
                
                if response.status_code != 200:
                    MATTERMOST_ERRORS.inc()
                    logger.error(
                        "Failed to send to Mattermost",
                        extra={
                            "status_code": response.status_code,
                            "response": response.text
                        }
                    )
                    raise HTTPException(status_code=500, detail="Failed to deliver to Mattermost")
                
                logger.info("Successfully sent alert to Mattermost")
        
        return JSONResponse(content={"status": "success"}, status_code=200)
    
    except Exception as e:
        logger.error("Error processing alert", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint for Docker."""
    return {"status": "healthy"}

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST) 