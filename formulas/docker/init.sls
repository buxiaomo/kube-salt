docker-pkg:
  pkg.installed:
    - pkgs:
      - bzip2
      - tar
      - unzip

/usr/local/src/docker-20.10.3.tgz:
  file.managed:
    - source: http://artifacts.splunk.org.cn/linux/static/stable/x86_64/docker-20.10.3.tgz
    - skip_verify: True

docker-extract:
  archive.extracted:
    - name: /usr/local/bin/
    - source: /usr/local/src/docker-20.10.3.tgz
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - clean: True

/etc/docker:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

docker-daemon:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://docker/files/daemon.json.j2
    - template: jinja
    - require:
      - file: /etc/docker

docker-systemd:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://docker/files/docker.service

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-pkg
      - file: docker-daemon
      - file: docker-systemd
    - watch:
      - file: docker-daemon
      - file: docker-systemd