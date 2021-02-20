# Kube Salt
<!-- [config/images] Pulled 
k8s.gcr.io/kube-apiserver:v1.17.4
[config/images] Pulled k8s.gcr.io/kube-controller-manager:v1.17.4
[config/images] Pulled k8s.gcr.io/kube-scheduler:v1.17.4
[config/images] Pulled k8s.gcr.io/kube-proxy:v1.17.4
[config/images] Pulled k8s.gcr.io/pause:3.1
[config/images] Pulled k8s.gcr.io/etcd:3.4.3-0
[config/images] Pulled k8s.gcr.io/coredns:1.6.5 
-->

curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh
sh /tmp/install_salt.sh -M stable 3000.6
sh /tmp/install_salt.sh stable 3000.6

## OS Support
CentOS 7.x+

Ubuntu 16.04+
## Install Salt Master
```
curl 
wget -O - https://repo.saltstack.com/py3/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

yum install https://repo.saltstack.com/py3/redhat/salt-py3-repo-2019.2.el7.noarch.rpm -y
yum clean expire-cache
yum install salt-master salt-api salt-minion -y
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
systemctl restart salt-master.service
systemctl enable salt-master.service
```

## Install Salt Minion
```
yum install https://repo.saltstack.com/py3/redhat/salt-py3-repo-2019.2.el7.noarch.rpm -y
yum clean expire-cache
yum install salt-minion -y
cat > /etc/salt/minion << EOF
master: 172.16.7.10
id: $(hostname)
startup_states: highstate
multiprocessing: false
retry_dns: 0
saltenv: local
mine_interval: 1
mine_enabled: Ture
mine_functions:
  grains.items: []
  network.interfaces: []
  network.ip_addrs:
    - ens192
EOF

cat > /etc/salt/minion.d/grains.conf << EOF
grains:
  roles:
    - ca
EOF

cat > /etc/salt/minion.d/grains.conf << EOF
grains:
  roles:
    - etcd
    - kube-master
EOF

cat > /etc/salt/minion.d/grains.conf << EOF
grains:
  roles:
    - kube-worker
EOF
systemctl restart salt-minion.service
systemctl enable salt-minion.service
```


## how to use
```
git clone https://github.com/buxiaomo/kube-salt.git /usr/local/src/kube-salt
cd /usr/local/src/kube-salt

# default version
make download
# custom version
make download KUBE_VERSION=1.17.4 DOCKER_VERSION=19.03.8 FLANNEL_VERSION=0.12.0 ETCD_VERSION=3.4.5

make init
make ca
make deploy
```

yum install epel-release -y
yum install gcc python3-pip python3-devel autoconf swig openssl-devel -y
pip3 install m2crypto
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple salt==2019.2.8
cat > /etc/systemd/system/salt-master.service << EOF
[Unit]
Description=The Salt Master Server
Documentation=man:salt-master(1) file:///usr/share/doc/salt/html/contents.html https://docs.saltstack.com/en/latest/contents.html
After=network.target

[Service]
LimitNOFILE=100000
Type=notify
NotifyAccess=all
ExecStart=/usr/local/bin/salt-master -l debug

[Install]
WantedBy=multi-user.target
EOF

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
ExecStart=/usr/local/bin/salt-minion -l debug

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/salt/minion.d

cat > /etc/salt/minion.d/grains.conf << EOF
grains:
  roles:
    - kube-minion
EOF