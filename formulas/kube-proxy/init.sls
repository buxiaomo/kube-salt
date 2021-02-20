{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kube-proxy-download:
  file.managed:
    - name: /usr/local/bin/kube-proxy
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-proxy
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

kube-proxy-config:
  file.managed:
    - name: /etc/kubernetes/kube-proxy.yaml
    - source: salt://kube-proxy/files/kube-proxy.yaml.j2
    - template: jinja

kube-proxy-systemd:
  file.managed:
    - name: /etc/systemd/system/kube-proxy.service
    - source: salt://kube-proxy/files/kube-proxy.service.j2
    - template: jinja