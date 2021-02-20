{% set kube_addon_location = salt['pillar.get']('kubernetes:location') %}

kube-addon-location:
  file.directory:
    - name: {{ kube_addon_location }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True