vercel:
  monitoring:
    prometheus:
      global:
        scrape_interval: {{ salt['pillar.get']('vercel:defaults:monitoring:interval', '15s') }}
        evaluation_interval: {{ salt['pillar.get']('vercel:defaults:monitoring:evaluation_interval', '15s') }}
      
      alerting:
        alertmanagers:
          - static_configs:
              - targets:
                - 'alertmanager:9093'
      
      rule_files:
        - "rules/*.yml"
      
      scrape_configs:
        - job_name: 'vercel-clients'
          metrics_path: /probe
          params:
            module: [http_2xx]
          static_configs:
            {% for client in salt['pillar.get']('vercel:clients', {}).items() %}
            - targets:
                - https://{{ client[1].domain }}
              labels:
                client: {{ client[0] }}
                environment: {{ client[1].environment }}
            {% endfor %}
          relabel_configs:
            - source_labels: [__address__]
              target_label: __param_target
            - source_labels: [__param_target]
              target_label: instance
            - target_label: __address__
              replacement: blackbox-exporter:9115
    
    alertmanager:
      global:
        resolve_timeout: 5m
      
      route:
        group_by: ['alertname', 'client', 'environment']
        group_wait: 30s
        group_interval: 5m
        repeat_interval: 4h
        receiver: 'mattermost'
      
      receivers:
        - name: 'mattermost'
          webhook_configs:
            - url: {{ salt['pillar.get']('vercel:defaults:alerts:notification_channels:mattermost:webhook_url') }}
              send_resolved: true
      
      inhibit_rules:
        - source_match:
            severity: 'critical'
          target_match:
            severity: 'warning'
          equal: ['alertname', 'client', 'environment'] 