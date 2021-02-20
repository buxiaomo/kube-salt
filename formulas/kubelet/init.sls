{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kubelet-download:
  file.managed:
    - name: /usr/local/bin/kubelet
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kubelet
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755