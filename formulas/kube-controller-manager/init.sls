{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kube-controller-manager-download:
  file.managed:
    - name: /usr/local/bin/kube-controller-manager
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

kube-controller-manager-systemd:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://kube-controller-manager/files/kube-controller-manager.service.j2
    - template: jinja