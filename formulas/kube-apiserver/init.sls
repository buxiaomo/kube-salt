{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kube-apiserver-download:
  file.managed:
    - name: /usr/local/bin/kube-apiserver
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

kube-apiserver-encryption-config:
  file.managed:
    - name: /etc/kubernetes/encryption-config.yaml
    - source: salt://kube-apiserver/files/encryption-config.yaml.j2
    - user: root
    - group: root
    - mode: 644

kube-apiserver-audit-policy-minimal:
  file.managed:
    - name: /etc/kubernetes/audit-policy-minimal.yaml
    - source: salt://kube-apiserver/files/audit-policy-minimal.yaml.j2
    - user: root
    - group: root
    - mode: 644

kube-apiserver-systemd:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://kube-apiserver/files/kube-apiserver.service.j2
    - template: jinja