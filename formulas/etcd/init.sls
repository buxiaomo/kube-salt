{% set etcd_version = salt['pillar.get']('etcd:version') %}
{% set datadir = salt['pillar.get']('etcd:datadir') %}

etcd_group_user:
  group.present:
    - name: etcd
    - system: True
  user.present:
    - name: etcd
    - createhome: False
    - groups:
      - etcd
    - require:
      - group: etcd

etcd-download:
  file.managed:
    - name: /usr/local/src/etcd-v{{ etcd_version }}-linux-amd64.tar.gz
    - source: http://artifacts.splunk.org.cn/coreos/etcd/releases/download/v{{ etcd_version }}/etcd-v{{ etcd_version }}-linux-amd64.tar.gz
    - skip_verify: True

etcd-extract:
  archive.extracted:
    - name: /usr/local/bin
    - source: /usr/local/src/etcd-v{{ etcd_version }}-linux-amd64.tar.gz
    - options: --strip-components=1 --exclude=Documentation --exclude='README*'
    - enforce_toplevel: False
    - clean: True

etcd-datadir:
  file.directory:
    - name: {{ datadir }}
    - user: etcd
    - group: etcd
    - mode: 700
    - makedirs: True

/etc/kubernetes/pki/etcd:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/kubernetes/pki/etcd/server.key:
  cmd.run:
    - name: openssl genrsa -out etcd/server.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/etcd/server.key
    - require:
      - file: /etc/kubernetes/pki/etcd
/etc/kubernetes/pki/etcd/server.csr:
  cmd.run:
    - name: openssl req -new -key etcd/server.key -subj "/CN=etcd-server" -out etcd/server.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/etcd/server.csr
    - require:
      - cmd: /etc/kubernetes/pki/etcd/server.key
/etc/kubernetes/pki/etcd/server.crt:
  cmd.run:
    - name: openssl x509 -in etcd/server.csr -req -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/server.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/etcd/server.csr
      - cmd: /etc/kubernetes/pki/etcd/server.key


/etc/kubernetes/pki/etcd/peer.key:
  cmd.run:
    - name: openssl genrsa -out etcd/peer.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/etcd/peer.key
    - require:
      - file: /etc/kubernetes/pki/etcd
/etc/kubernetes/pki/etcd/peer.csr:
  cmd.run:
    - name: openssl req -new -key etcd/peer.key -subj "/CN=etcd-peer" -out etcd/peer.csr 
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/etcd/peer.csr
    - require:
      - cmd: /etc/kubernetes/pki/etcd/peer.key
/etc/kubernetes/pki/etcd/peer.crt:
  cmd.run:
    - name: openssl x509 -in etcd/peer.csr -req -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/peer.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/etcd/peer.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/etcd/peer.csr
      - cmd: /etc/kubernetes/pki/etcd/peer.key


/etc/kubernetes/pki/etcd/healthcheck-client.key:
  cmd.run:
    - name: openssl genrsa -out etcd/healthcheck-client.key 2048
    - user: root
    - group: root
    - cwd: /etc/kubernetes/pki
    - makedirs: True
    - env:
      - RANDFILE: /tmp/.random
    - makedirs: True
    - unless: test -f /etc/kubernetes/pki/etcd/healthcheck-client.key
    - require:
      - file: /etc/kubernetes/pki/etcd
/etc/kubernetes/pki/etcd/healthcheck-client.csr:
  cmd.run:
    - name: openssl req -new -key etcd/healthcheck-client.key -subj "/CN=etcd-client" -out etcd/healthcheck-client.csr
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: test -f /etc/kubernetes/pki/etcd/healthcheck-client.csr
    - require:
      - cmd: /etc/kubernetes/pki/etcd/healthcheck-client.key
/etc/kubernetes/pki/etcd/healthcheck-client.crt:
  cmd.run:
    - name: openssl x509 -in etcd/healthcheck-client.csr -req -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/healthcheck-client.crt -days 3652
    - user: root
    - group: root
    - makedirs: True
    - cwd: /etc/kubernetes/pki
    - env:
      - RANDFILE: /tmp/.random
    - unless: openssl x509 -in /etc/kubernetes/pki/etcd/healthcheck-client.crt -noout -text -checkend 2592000
    - require:
      - cmd: /etc/kubernetes/pki/etcd/healthcheck-client.csr
      - cmd: /etc/kubernetes/pki/etcd/healthcheck-client.key

etcd-systemd:
  file.managed:
    - name: /etc/systemd/system/etcd.service
    - source: salt://etcd/files/etcd.service.j2
    - template: jinja

etcd-check:
  file.managed:
    - name: /usr/local/bin/etcd-check
    - source: salt://etcd/files/etcd-check.j2
    - template: jinja
    - mode: 755

etcd-service:
  service.running:
    - name: etcd
    - enable: True
    - require:
      - file: etcd-download
      - archive: etcd-extract
      - file: etcd-systemd
    - watch:
      - file: etcd-systemd
      - cmd: /etc/kubernetes/pki/etcd/server.key
      - cmd: /etc/kubernetes/pki/etcd/server.crt
      - cmd: /etc/kubernetes/pki/etcd/peer.key
      - cmd: /etc/kubernetes/pki/etcd/peer.crt