{% set kube_version = salt['pillar.get']('kubernetes:version') %}

kubelet-download:
  file.managed:
    - name: /usr/local/bin/kubelet
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kubelet
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

kubelet-config:
  file.managed:
    - name: /etc/kubernetes/kubelet.yaml
    - source: salt://kubelet/files/kubelet.yaml.j2
    - template: jinja

kubelet-systemd:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source: salt://kubelet/files/kubelet.service.j2
    - template: jinja