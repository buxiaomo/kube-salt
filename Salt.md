# Salt

## Salt Master

```
mdir -p /etc/salt
cat > /etc/salt/master << EOF
interface: 0.0.0.0
ipv6: False
publish_port: 4505
ret_port: 4506
pidfile: /var/run/salt-master.pid
syndic_master_port: 4506
auto_accept: True
worker_threads: 5
root_dir: /
log_file: /var/log/salt/master
log_level: warning
nodegroups:
  group_all: '*'
file_roots:
  local:
    - /srv/salt/local
    - /srv/salt/local/roles
    - /srv/formulas
pillar_roots:
  local:
    - /srv/pillar/local
default_include: master.d/*.conf
EOF
```

```
cat > /etc/systemd/system/salt-master.service << EOF
[Unit]
Description=The Salt Master Server
Documentation=man:salt-master(1) file:///usr/share/doc/salt/html/contents.html https://docs.saltstack.com/en/latest/contents.html
After=network.target

[Service]
LimitNOFILE=100000
Type=notify
NotifyAccess=all
ExecStart=/usr/local/bin/salt-master

[Install]
WantedBy=multi-user.target
EOF
```

```
cat > /etc/systemd/system/salt-minion.service << EOF
[Unit]
Description=The Salt Minion
Documentation=man:salt-minion(1) file:///usr/share/doc/salt/html/contents.html https://docs.saltstack.com/en/latest/contents.html
After=network.target salt-master.service

[Service]
KillMode=process
Type=notify
NotifyAccess=all
LimitNOFILE=8192
ExecStart=/usr/local/bin/salt-minion

[Install]
WantedBy=multi-user.target
EOF
```