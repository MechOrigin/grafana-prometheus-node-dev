import yaml
import os
from typing import Dict, Any
from pydantic import BaseModel, Field

class MattermostConfig(BaseModel):
    webhook_url: str = Field(..., description="Mattermost webhook URL")
    timeout: int = Field(default=5, description="Webhook timeout in seconds")

class AlertTemplates(BaseModel):
    critical: Dict[str, str] = Field(..., description="Critical alert template")
    warning: Dict[str, str] = Field(..., description="Warning alert template")
    info: Dict[str, str] = Field(..., description="Info alert template")

class Config(BaseModel):
    mattermost: MattermostConfig
    templates: AlertTemplates

def load_config() -> Dict[str, Any]:
    """Load and validate configuration from file and environment variables."""
    
    # Default config path
    config_path = os.getenv('CONFIG_PATH', '/app/config/config.yml')
    
    # Load config file
    try:
        with open(config_path, 'r') as f:
            config_data = yaml.safe_load(f)
    except Exception as e:
        raise RuntimeError(f"Failed to load config file: {e}")
    
    # Override with environment variables if present
    if webhook_url := os.getenv('MATTERMOST_WEBHOOK_URL'):
        config_data['mattermost']['webhook_url'] = webhook_url
    
    # Validate config
    try:
        config = Config(**config_data)
        return config.dict()
    except Exception as e:
        raise RuntimeError(f"Invalid configuration: {e}") 