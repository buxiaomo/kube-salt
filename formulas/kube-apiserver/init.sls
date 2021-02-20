{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kube-apiserver-download:
  file.managed:
    - name: /usr/local/bin/kube-apiserver
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755