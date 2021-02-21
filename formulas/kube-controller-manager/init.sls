include:
  - certificate

{% set kube_version = salt['pillar.get']('kubernetes:version') %}
{%- set advertise_address = salt['grains.get']('saltstack_default_ipv4') -%}

/usr/local/bin/kube-controller-manager:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

/etc/kubernetes/pki/kube-controller-manager.key:
  cmd.run:
    - name: openssl genrsa -out kube-controller-manager.key 2048
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/kube-controller-manager.key
/etc/kubernetes/pki/kube-controller-manager.csr:
  cmd.run:
    - name: openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager/O=system:kube-controller-manager" -out kube-controller-manager.csr
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/kube-controller-manager.csr
    - require:
      - cmd: /etc/kubernetes/pki/kube-controller-manager.key
/etc/kubernetes/pki/kube-controller-manager.crt:
  cmd.run:
    - name: openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out kube-controller-manager.crt -days 3652
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/kube-controller-manager.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/kube-controller-manager.csr
      - sls: certificate

kube-controller-manager-kubeconfig-cluster:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-cluster kubernetes --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://{{ advertise_address }}:6443 --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig
    - cwd: /etc/kubernetes
    - require:
      - sls: certificate
    - watch:
      - sls: certificate
kube-controller-manager-kubeconfig-credentials:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-credentials 'system:kube-controller-manager' --embed-certs=true --client-certificate=/etc/kubernetes/pki/kube-controller-manager.crt --client-key=/etc/kubernetes/pki/kube-controller-manager.key --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig
    - cwd: /etc/kubernetes
    - require:
      - cmd: /etc/kubernetes/pki/kube-controller-manager.key
      - cmd: /etc/kubernetes/pki/kube-controller-manager.crt
    - watch:
      - cmd: /etc/kubernetes/pki/kube-controller-manager.key
      - cmd: /etc/kubernetes/pki/kube-controller-manager.crt
kube-controller-manager-kubeconfig-set-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-context 'system:kube-controller-manager@kubernetes' --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-controller-manager-kubeconfig-cluster
      - cmd: kube-controller-manager-kubeconfig-credentials
    - watch:
      - cmd: kube-controller-manager-kubeconfig-cluster
      - cmd: kube-controller-manager-kubeconfig-credentials

kube-controller-manager-kubeconfig-use-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config use-context 'system:kube-controller-manager@kubernetes' --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig 
    - cwd: /etc/kubernetes
    - require:
      - cmd: kube-controller-manager-kubeconfig-set-context

/etc/systemd/system/kube-controller-manager.service:
  file.managed:
    - source: salt://kube-controller-manager/files/kube-controller-manager.service.j2
    - template: jinja

kube-controller-manager-service:
  service.running:
    - name: kube-controller-manager
    - enable: True
    - require:
      - file: /usr/local/bin/kube-controller-manager
      - file: /etc/systemd/system/kube-controller-manager.service
      - cmd: /etc/kubernetes/pki/kube-controller-manager.crt
    - watch:
      - file: /usr/local/bin/kube-controller-manager
      - file: /etc/systemd/system/kube-controller-manager.service
      - cmd: /etc/kubernetes/pki/kube-controller-manager.crt