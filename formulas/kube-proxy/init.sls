{% set kube_version = salt['pillar.get']('kubernetes:version') %}

{%- set advertise_address = salt['grains.get']('saltstack_default_ipv4') -%}

/usr/local/bin/kube-proxy:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-proxy
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

/etc/kubernetes/pki/kube-proxy.key:
  cmd.run:
    - name: openssl genrsa -out kube-proxy.key 2048
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/kube-proxy.key

/etc/kubernetes/pki/kube-proxy.csr:
  cmd.run:
    - name: openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy/O=system:node-proxier" -out kube-proxy.csr
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/kube-proxy.csr
    - require:
      - cmd: /etc/kubernetes/pki/kube-proxy.key

/etc/kubernetes/pki/kube-proxy.crt:
  cmd.run:
    - name: openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out kube-proxy.crt -days 3652
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/kube-proxy.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/kube-proxy.csr

kube-proxy-kubeconfig-cluster:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-cluster kubernetes --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://{{ advertise_address }}:6443 --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes

kube-proxy-kubeconfig-credentials:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-credentials kube-proxy --embed-certs=true --client-certificate=/etc/kubernetes/pki/kube-proxy.crt --client-key=/etc/kubernetes/pki/kube-proxy.key --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-proxy-kubeconfig-cluster

kube-proxy-kubeconfig-set-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-context kubernetes --cluster=kubernetes --user=kube-proxy --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-proxy-kubeconfig-credentials

kube-proxy-kubeconfig-use-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config use-context kubernetes --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-proxy-kubeconfig-set-context

/etc/kubernetes/kube-proxy.yaml:
  file.managed:
    - source: salt://kube-proxy/files/kube-proxy.yaml.j2
    - template: jinja
    - makedirs: True

/etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://kube-proxy/files/kube-proxy.service.j2
    - template: jinja

kube-proxy-service:
  service.running:
    - name: kube-proxy
    - enable: True
    - require:
      - file: /usr/local/bin/kube-proxy
      - file: /etc/systemd/system/kube-proxy.service
      - file: /etc/kubernetes/kube-proxy.yaml
      - cmd: /etc/kubernetes/pki/kube-proxy.crt
      - cmd: /etc/kubernetes/pki/kube-proxy.key
    - watch:
      - file: /usr/local/bin/kube-proxy
      - file: /etc/systemd/system/kube-proxy.service
      - file: /etc/kubernetes/kube-proxy.yaml
      - cmd: /etc/kubernetes/pki/kube-proxy.crt
      - cmd: /etc/kubernetes/pki/kube-proxy.key