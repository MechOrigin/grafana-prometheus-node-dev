include:
  - vercel-clients.prometheus
  - vercel-clients.alertmanager
  - vercel-clients.blackbox

vercel-clients-monitoring-dirs:
  file.directory:
    - names:
      - /etc/prometheus/rules
      - /etc/prometheus/file_sd
    - makedirs: True
    - user: solheimtech
    - group: staff
    - mode: 755

vercel-clients-prometheus-config:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - source: salt://vercel-clients/files/prometheus/prometheus.yml
    - template: jinja
    - user: solheimtech
    - group: staff
    - mode: 644
    - require:
      - file: vercel-clients-monitoring-dirs

vercel-clients-alertmanager-config:
  file.managed:
    - name: /etc/alertmanager/alertmanager.yml
    - source: salt://vercel-clients/files/alertmanager/alertmanager.yml
    - template: jinja
    - user: solheimtech
    - group: staff
    - mode: 644
    - require:
      - file: vercel-clients-monitoring-dirs

vercel-clients-blackbox-config:
  file.managed:
    - name: /etc/blackbox/blackbox.yml
    - source: salt://vercel-clients/files/blackbox/blackbox.yml
    - template: jinja
    - user: solheimtech
    - group: staff
    - mode: 644
    - require:
      - file: vercel-clients-monitoring-dirs

vercel-clients-prometheus-rules:
  file.recurse:
    - name: /etc/prometheus/rules
    - source: salt://vercel-clients/files/prometheus/rules
    - template: jinja
    - user: solheimtech
    - group: staff
    - dir_mode: 755
    - file_mode: 644
    - require:
      - file: vercel-clients-monitoring-dirs 