from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
import requests
import logging
from prometheus_client import Counter, Histogram, start_http_server
import time
from .config import load_config
from .utils.transformer import transform_alert

# Initialize FastAPI app
app = FastAPI()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Prometheus metrics
ALERT_COUNTER = Counter('alert_bridge_alerts_total', 'Total number of alerts received', ['severity'])
ALERT_LATENCY = Histogram('alert_bridge_processing_seconds', 'Time spent processing alerts')
MATTERMOST_ERRORS = Counter('alert_bridge_mattermost_errors_total', 'Total number of Mattermost delivery errors')

# Load configuration
config = load_config()

@app.post("/api/v2/alerts")
async def receive_alert(request: Request):
    try:
        alert_data = await request.json()
        logger.info("Received alert", extra={"alert_data": alert_data})
        
        with ALERT_LATENCY.time():
            # Handle both list and dictionary inputs
            alerts = alert_data if isinstance(alert_data, list) else [alert_data]
            
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

# Start Prometheus metrics server
start_http_server(8000) 