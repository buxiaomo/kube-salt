include:
  - certificate

{% set kube_version = salt['pillar.get']('kubernetes:version') %}
{% set advertise_address = salt['grains.get']('saltstack_default_ipv4') %}

/usr/local/bin/kubectl:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kubectl
    - skip_verify: True
    - user: root
    - group: root
    - mode: 711

/etc/kubernetes/pki/admin.key:
  cmd.run:
    - name: openssl genrsa -out admin.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/admin.key

/etc/kubernetes/pki/admin.csr:
  cmd.run:
    - name: openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/admin.csr
    - require:
      - cmd: /etc/kubernetes/pki/admin.key

/etc/kubernetes/pki/admin.crt:
  cmd.run:
    - name: openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out admin.crt -days 3652
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: openssl x509 -in admin.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/admin.csr
      - sls: certificate

admin-kubeconfig-cluster:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://{{ advertise_address }}:6443 --embed-certs=true --kubeconfig=/etc/kubernetes/admin.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - unless: test -f /etc/kubernetes/admin.kubeconfig
    - require:
      - sls: certificate
    - watch:
      - sls: certificate

admin-kubeconfig-credentials:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-credentials admin --client-certificate=/etc/kubernetes/pki/admin.crt --client-key=/etc/kubernetes/pki/admin.key --embed-certs=true --kubeconfig=/etc/kubernetes/admin.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: /etc/kubernetes/pki/admin.key
      - cmd: /etc/kubernetes/pki/admin.crt
    - watch:
      - cmd: /etc/kubernetes/pki/admin.key
      - cmd: /etc/kubernetes/pki/admin.crt

admin-kubeconfig-set-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-context admin@kubernetes --cluster=kubernetes --user=admin --kubeconfig=/etc/kubernetes/admin.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: admin-kubeconfig-cluster
      - cmd: admin-kubeconfig-credentials
    - watch:
      - cmd: admin-kubeconfig-cluster
      - cmd: admin-kubeconfig-credentials

admin-kubeconfig-use-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config use-context admin@kubernetes --kubeconfig=/etc/kubernetes/admin.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: admin-kubeconfig-set-context
    - watch:
      - cmd: admin-kubeconfig-set-context

/root/.kube/config:
  file.symlink:
    - target: /etc/kubernetes/admin.kubeconfig
    - force: True
    - makedirs: True
    - require:
      - cmd: admin-kubeconfig-use-context
    - watch:
      - cmd: admin-kubeconfig-use-context

/etc/bash_completion.d/kubectl:
  file.managed:
    - source: salt://kubectl/files/kubectl.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True