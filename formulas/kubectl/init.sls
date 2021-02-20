{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kubectl-download:
  file.managed:
    - name: /usr/local/bin/kubectl
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kubectl
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755