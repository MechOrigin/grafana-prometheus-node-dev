alertmanager:
  cmd.run:
    - name: echo "Alertmanager is already installed manually at /usr/local/bin/alertmanager"
    - unless: test -f /usr/local/bin/alertmanager
