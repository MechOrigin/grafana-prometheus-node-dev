include:
  - vercel-clients.init

resend-key-script:
  file.managed:
    - name: /usr/local/bin/fetch_resend_key.sh
    - source: salt://vercel-clients/files/scripts/fetch_resend_key.sh
    - template: jinja
    - mode: '755'
    - user: root
    - group: root
    - require:
      - file: vercel-clients-monitoring-dirs

resend-key-cron:
  cron.present:
    - name: /usr/local/bin/fetch_resend_key.sh
    - user: root
    - minute: '*/30'  # Run every 30 minutes
    - require:
      - file: resend-key-script

resend-key-initial-fetch:
  cmd.run:
    - name: /usr/local/bin/fetch_resend_key.sh
    - require:
      - file: resend-key-script
      - cron: resend-key-cron