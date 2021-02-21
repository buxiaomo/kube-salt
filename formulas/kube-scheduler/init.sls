{% set kube_version = salt['pillar.get']('kubernetes:version') %}
{%- set advertise_address = salt['grains.get']('saltstack_default_ipv4') -%}
/etc/kubernetes/pki/kube-scheduler.key:
  cmd.run:
    - name: openssl genrsa -out kube-scheduler.key 2048
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/kube-scheduler.key

/etc/kubernetes/pki/kube-scheduler.csr:
  cmd.run:
    - name: openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler/O=system:kube-scheduler" -out kube-scheduler.csr
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/kube-scheduler.csr
    - require:
      - cmd: /etc/kubernetes/pki/kube-scheduler.key

/etc/kubernetes/pki/kube-scheduler.crt:
  cmd.run:
    - name: openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out kube-scheduler.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/kube-scheduler.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/kube-scheduler.csr

kube-scheduler-kubeconfig-cluster:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-cluster kubernetes --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://{{ advertise_address }}:6443 --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: /etc/kubernetes/pki/kube-scheduler.crt

kube-scheduler-kubeconfig-credentials:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-credentials system:kube-scheduler --embed-certs=true --client-certificate=/etc/kubernetes/pki/kube-scheduler.crt --client-key=/etc/kubernetes/pki/kube-scheduler.key --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-scheduler-kubeconfig-cluster

kube-scheduler-kubeconfig-set-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-scheduler-kubeconfig-credentials

kube-scheduler-kubeconfig-use-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config use-context system:kube-scheduler@kubernetes --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-scheduler-kubeconfig-set-context

/usr/local/bin/kube-scheduler:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-scheduler
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

/etc/systemd/system/kube-scheduler.service:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://kube-scheduler/files/kube-scheduler.service.j2
    - template: jinja

kube-scheduler-service:
  service.running:
    - name: kube-scheduler
    - enable: True
    - require:
      - file: /usr/local/bin/kube-scheduler
      - file: /etc/systemd/system/kube-scheduler.service
      - cmd: /etc/kubernetes/pki/kube-scheduler.crt
    - watch:
      - file: /usr/local/bin/kube-scheduler
      - file: /etc/systemd/system/kube-scheduler.service
      - cmd: /etc/kubernetes/pki/kube-scheduler.crt