{% set kube_version = salt['pillar.get']('kubernetes:version') %}

/usr/local/bin/kube-apiserver:
  file.managed:
    - source: http://artifacts.splunk.org.cn/kubernetes-release/release/v{{ kube_version }}/bin/linux/amd64/kube-apiserver
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755

/etc/kubernetes/pki/apiserver.key:
  cmd.run:
    - name: openssl genrsa -out apiserver.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/apiserver.key
/etc/kubernetes/pki/apiserver.csr:
  cmd.run:
    - name: openssl req -new -key apiserver.key -subj "/CN=kube-apiserver/O=Kubernetes" -config openssl.cnf -out apiserver.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/apiserver.csr
    - require:
      - cmd: /etc/kubernetes/pki/apiserver.key
/etc/kubernetes/pki/apiserver.crt:
  cmd.run:
    - name: openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_apiserver -extfile openssl.cnf -out apiserver.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/apiserver.csr


/etc/kubernetes/pki/front-proxy-client.key:
  cmd.run:
    - name: openssl genrsa -out front-proxy-client.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/front-proxy-client.key
/etc/kubernetes/pki/front-proxy-client.csr:
  cmd.run:
    - name: openssl req -new -key front-proxy-client.key -subj "/CN=front-proxy-client" -out front-proxy-client.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/front-proxy-client.csr
    - require:
      - cmd: /etc/kubernetes/pki/front-proxy-client.key
/etc/kubernetes/pki/front-proxy-client.crt:
  cmd.run:
    - name: openssl x509 -req -in front-proxy-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out front-proxy-client.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/front-proxy-client.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/front-proxy-client.csr

/etc/kubernetes/pki/apiserver-kubelet-client.key:
  cmd.run:
    - name: openssl genrsa -out apiserver-kubelet-client.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/apiserver-kubelet-client.key
/etc/kubernetes/pki/apiserver-kubelet-client.csr:
  cmd.run:
    - name: openssl req -new -key apiserver-kubelet-client.key -subj "/CN=apiserver-kubelet-client/O=system:masters" -out apiserver-kubelet-client.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/apiserver-kubelet-client.csr
    - require:
      - cmd: /etc/kubernetes/pki/apiserver-kubelet-client.key
/etc/kubernetes/pki/apiserver-kubelet-client.crt:
  cmd.run:
    - name: openssl x509 -req -in apiserver-kubelet-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_client -extfile openssl.cnf -out apiserver-kubelet-client.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/apiserver-kubelet-client.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/apiserver-kubelet-client.csr

/etc/kubernetes/pki/apiserver-etcd-client.key:
  cmd.run:
    - name: openssl genrsa -out apiserver-etcd-client.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/apiserver-etcd-client.key
/etc/kubernetes/pki/apiserver-etcd-client.csr:
  cmd.run:
    - name: openssl req -new -key apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client/O=system:masters" -out apiserver-etcd-client.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/apiserver-etcd-client.csr
    - require:
      - cmd: /etc/kubernetes/pki/apiserver-etcd-client.key
/etc/kubernetes/pki/apiserver-etcd-client.crt:
  cmd.run:
    - name: openssl x509 -in apiserver-etcd-client.csr -req -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out apiserver-etcd-client.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/apiserver-etcd-client.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/apiserver-etcd-client.csr
      - cmd: /etc/kubernetes/pki/apiserver-etcd-client.key

/etc/kubernetes/encryption-config.yaml:
  file.managed:
    - source: salt://kube-apiserver/files/encryption-config.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja

/etc/kubernetes/audit-policy-minimal.yaml:
  file.managed:
    - source: salt://kube-apiserver/files/audit-policy-minimal.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/etc/systemd/system/kube-apiserver.service:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://kube-apiserver/files/kube-apiserver.service.j2
    - template: jinja

kube-apiserver-service:
  service.running:
    - name: kube-apiserver
    - enable: True
    - require:
      - file: /usr/local/bin/kube-apiserver
      - file: /etc/systemd/system/kube-apiserver.service
      - file: /etc/kubernetes/audit-policy-minimal.yaml
      - file: /etc/kubernetes/encryption-config.yaml
    - watch:
      - file: /usr/local/bin/kube-apiserver
      - file: /etc/systemd/system/kube-apiserver.service