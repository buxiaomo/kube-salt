include:
  - certificate

{% set kube_version = salt['pillar.get']('kubernetes:version') %}
{%- set hostname_override = salt['grains.get']('id') -%}
{%- set advertise_address = salt['grains.get']('saltstack_default_ipv4') -%}

/usr/local/bin/kubelet:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kubelet
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

/etc/kubernetes/pki/kubelet.key:
  cmd.run:
    - name: openssl genrsa -out kubelet.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/kubelet.key
/etc/kubernetes/pki/kubelet.csr:
  cmd.run:
    - name: openssl req -new -key kubelet.key -subj "/CN=system:node:{{ hostname_override | lower }}/O=system:nodes" -out kubelet.csr
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/kubelet.csr
    - require:
      - cmd: /etc/kubernetes/pki/kubelet.key
/etc/kubernetes/pki/kubelet.crt:
  cmd.run:
    - name: openssl x509 -req -in kubelet.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out kubelet.crt -days 3652
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: openssl x509 -in kubelet.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/kubelet.csr
      - sls: certificate

kubelet-kubeconfig-cluster:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-cluster kubernetes --embed-certs=true --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://{{ advertise_address }}:6443 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - sls: certificate
kubelet-kubeconfig-credentials:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-credentials system:node:{{ hostname_override }} --embed-certs=true --client-certificate=/etc/kubernetes/pki/kubelet.crt --client-key=/etc/kubernetes/pki/kubelet.key --kubeconfig=/etc/kubernetes/kubelet.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: /etc/kubernetes/pki/kubelet.key
      - cmd: /etc/kubernetes/pki/kubelet.crt
    - watch:
      - cmd: /etc/kubernetes/pki/kubelet.key
      - cmd: /etc/kubernetes/pki/kubelet.crt
kubelet-kubeconfig-set-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config set-context kubernetes --cluster=kubernetes --user=system:node:{{ hostname_override }} --kubeconfig=/etc/kubernetes/kubelet.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kubelet-kubeconfig-credentials
      - cmd: kubelet-kubeconfig-cluster
    - watch:
      - cmd: kubelet-kubeconfig-credentials
      - cmd: kubelet-kubeconfig-cluster
kubelet-kubeconfig-use-context:
  cmd.run:
    - name: /usr/local/bin/kubectl config use-context kubernetes --kubeconfig=/etc/kubernetes/kubelet.kubeconfig
    - user: root
    - group: root
    - cwd: /etc/kubernetes
    - require:
      - cmd: kubelet-kubeconfig-set-context

/etc/kubernetes/kubelet.yaml:
  file.managed:
    - source: salt://kubelet/files/kubelet.yaml.j2
    - template: jinja
    - makedirs: True

/etc/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

unmount-swaps:
  cmd.run:
    - name: /sbin/swapoff -a

/etc/systemd/system/kubelet.service:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source: salt://kubelet/files/kubelet.service.j2
    - template: jinja

kubelet-service:
  service.running:
    - name: kubelet
    - enable: True
    - require:
      - file: /usr/local/bin/kubelet
      - file: /etc/kubernetes/kubelet.yaml
      - file: /etc/systemd/system/kubelet.service
      - cmd: /etc/kubernetes/pki/kubelet.crt
      - file: /etc/kubernetes/manifests
      - cmd: unmount-swaps
    - watch:
      - file: /usr/local/bin/kubelet
      - file: /etc/kubernetes/kubelet.yaml
      - file: /etc/systemd/system/kubelet.service
      - cmd: /etc/kubernetes/pki/kubelet.crt