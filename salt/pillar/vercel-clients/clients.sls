vercel:
  clients:
    {% for client in salt['pillar.get']('vercel:client_list', []) %}
    {{ client.name }}:
      domain: {{ client.domain }}
      environment: {{ client.environment }}
      monitoring:
        enabled: {{ client.monitoring.enabled | default(true) }}
        endpoints:
          - name: "{{ client.name }}-main"
            url: "https://{{ client.domain }}"
            interval: {{ client.monitoring.interval | default('15s') }}
          {% if client.monitoring.additional_endpoints %}
          {% for endpoint in client.monitoring.additional_endpoints %}
          - name: "{{ client.name }}-{{ endpoint.name }}"
            url: "{{ endpoint.url }}"
            interval: {{ endpoint.interval | default('15s') }}
          {% endfor %}
          {% endif %}
        
        alerts:
          {% if client.alerts %}
          custom_rules:
            {% for rule in client.alerts.rules %}
            - name: "{{ rule.name }}"
              expr: "{{ rule.expr }}"
              for: "{{ rule.for }}"
              labels:
                severity: "{{ rule.severity }}"
                client: "{{ client.name }}"
              annotations:
                summary: "{{ rule.summary }}"
                description: "{{ rule.description }}"
            {% endfor %}
          {% endif %}
          
        integrations:
          {% if client.integrations %}
          {% for integration in client.integrations %}
          {{ integration.name }}:
            enabled: {{ integration.enabled | default(true) }}
            config: {{ integration.config | default({}) }}
          {% endfor %}
          {% endif %}
    {% endfor %} 