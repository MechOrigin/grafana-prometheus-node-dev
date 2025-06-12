include:
  - vercel-clients.init

grafana-dashboard-dir:
  file.directory:
    - name: /etc/grafana/provisioning/dashboards
    - makedirs: True
    - user: grafana
    - group: grafana
    - mode: 755

grafana-dashboard-config:
  file.managed:
    - name: /etc/grafana/provisioning/dashboards/dispensariesguide.yaml
    - source: salt://vercel-clients/files/grafana/dashboards/dispensariesguide.yaml
    - template: jinja
    - user: grafana
    - group: grafana
    - mode: 644
    - require:
      - file: grafana-dashboard-dir

grafana-dashboard-json:
  file.managed:
    - name: /etc/grafana/provisioning/dashboards/dispensariesguide-resend.json
    - source: salt://vercel-clients/files/grafana/dashboards/dispensariesguide-resend.json
    - template: jinja
    - user: grafana
    - group: grafana
    - mode: 644
    - require:
      - file: grafana-dashboard-dir

grafana-service:
  service.running:
    - name: grafana-server
    - enable: True
    - watch:
      - file: grafana-dashboard-config
      - file: grafana-dashboard-json 