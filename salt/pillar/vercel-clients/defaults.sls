vercel:
  defaults:
    monitoring:
      enabled: true
      interval: 15s
      evaluation_interval: 15s
      scrape_timeout: 10s
      
    alerts:
      severity_levels:
        - critical
        - warning
        - info
      
      notification_channels:
        mattermost:
          enabled: true
          webhook_url: {{ salt['pillar.get']('mattermost:webhook_url') }}
          channel: "monitoring-alerts"
      
    metrics:
      endpoints:
        - path: /api/metrics
          interval: 15s
        - path: /api/health
          interval: 30s
      
    blackbox:
      modules:
        http_2xx:
          timeout: 5s
          valid_status_codes: [200, 201, 202, 204]
          valid_http_versions: ["HTTP/1.0", "HTTP/1.1", "HTTP/2.0"]
          tls_config:
            insecure_skip_verify: true 