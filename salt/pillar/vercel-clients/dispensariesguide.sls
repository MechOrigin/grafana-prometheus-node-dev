vercel:
  client_list:
    - name: dispensariesguide
      domain: www.dispensariesguide.com
      environment: production
      monitoring:
        enabled: true
        interval: 15s
        additional_endpoints:
          - name: api
            url: https://www.dispensariesguide.com/api
            interval: 15s
          - name: resend
            url: https://api.resend.com/emails
            interval: 30s
        alerts:
          rules:
            - name: "DispensariesGuide_ResendAPI_Down"
              expr: "probe_success{job='vercel-clients', instance='https://api.resend.com/emails'} == 0"
              for: "1m"
              severity: "critical"
              summary: "Resend API is down for DispensariesGuide"
              description: "Resend API endpoint is not responding. This will affect email delivery for DispensariesGuide."
            
            - name: "DispensariesGuide_ResendHighLatency"
              expr: "probe_duration_seconds{job='vercel-clients', instance='https://api.resend.com/emails'} > 1"
              for: "5m"
              severity: "warning"
              summary: "Resend API high latency for DispensariesGuide"
              description: "Resend API is experiencing high latency (above 1 second) for more than 5 minutes."
            
            - name: "DispensariesGuide_EmailDeliveryFailure"
              expr: "rate(resend_email_delivery_failures_total{client='dispensariesguide'}[5m]) > 0"
              for: "1m"
              severity: "critical"
              summary: "Email delivery failures for DispensariesGuide"
              description: "Resend is reporting email delivery failures for DispensariesGuide."
            
            - name: "DispensariesGuide_WebsiteDown"
              expr: "probe_success{job='vercel-clients', instance='https://www.dispensariesguide.com'} == 0"
              for: "1m"
              severity: "critical"
              summary: "DispensariesGuide website is down"
              description: "DispensariesGuide website is not responding."
            
            - name: "DispensariesGuide_HighResponseTime"
              expr: "probe_duration_seconds{job='vercel-clients', instance='https://www.dispensariesguide.com'} > 2"
              for: "5m"
              severity: "warning"
              summary: "DispensariesGuide website high response time"
              description: "DispensariesGuide website is experiencing high response times (above 2 seconds) for more than 5 minutes."
        
        integrations:
          resend:
            enabled: true
            config:
              api_key: {{ salt['pillar.get']('resend:api_key') }}
              metrics_endpoint: /api/metrics/resend
              alert_threshold: 1 