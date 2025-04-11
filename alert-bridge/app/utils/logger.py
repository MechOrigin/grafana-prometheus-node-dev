import logging
import sys
from pythonjsonlogger import jsonlogger

def setup_logger(name: str = "alert_bridge") -> logging.Logger:
    """Setup structured JSON logging."""
    logger = logging.getLogger(name)
    
    # Clear any existing handlers
    logger.handlers = []
    
    # Create console handler
    handler = logging.StreamHandler(sys.stdout)
    
    # Create formatter
    formatter = jsonlogger.JsonFormatter(
        fmt="%(asctime)s %(levelname)s %(name)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    
    # Set handler formatter
    handler.setFormatter(formatter)
    
    # Add handler to logger
    logger.addHandler(handler)
    
    # Set log level
    logger.setLevel(logging.INFO)
    
    return logger 