# -*- coding: utf-8 -*-
# vim: ft=sls

limits:
  file.managed:
    - name: /etc/security/limits.d/99-kubernetes.conf
    - source: salt://limits/files/99-kubernetes.conf