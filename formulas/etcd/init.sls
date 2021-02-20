{% set etcd_version = salt['pillar.get']('etcd:version') %}

etcd-download:
  file.managed:
    - name: /usr/local/src/etcd-v{{ etcd_version }}-linux-amd64.tar.gz
    - source: http://artifacts.splunk.org.cn/coreos/etcd/releases/download/v{{ etcd_version }}/etcd-v{{ etcd_version }}-linux-amd64.tar.gz

etcd-extract:
  archive.extracted:
    - name: /tmp/
    - source: /usr/local/src/etcd-v{{ etcd_version }}-linux-amd64.tar.gz
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - clean: True