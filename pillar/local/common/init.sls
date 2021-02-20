timezone:
  name: Asia/Shanghai

chrony:
  ntpservers:
    - 'ntp1.aliyun.com'
    - 'ntp2.aliyun.com'
    - 'ntp3.aliyun.com'
    - 'ntp4.aliyun.com'

sysctl:
  params:
    net.ipv4.tcp_keepalive_time: 600
    net.ipv4.tcp_keepalive_intvl: 30
    net.ipv4.tcp_keepalive_probes: 10
    net.ipv6.conf.all.disable_ipv6: 1
    net.ipv6.conf.default.disable_ipv6: 1
    net.ipv6.conf.lo.disable_ipv6: 1
    net.ipv4.neigh.default.gc_stale_time: 120
    net.ipv4.conf.all.rp_filter: 0
    net.ipv4.conf.default.rp_filter: 0
    net.ipv4.conf.default.arp_announce: 2
    net.ipv4.conf.lo.arp_announce: 2
    net.ipv4.conf.all.arp_announce: 2
    net.ipv4.ip_forward: 1
    net.ipv4.tcp_max_tw_buckets: 5000
    net.ipv4.tcp_syncookies: 1
    net.ipv4.tcp_max_syn_backlog: 1024
    net.ipv4.tcp_synack_retries: 2
    fs.inotify.max_user_watches: 89100
    fs.file-max: 52706963
    fs.nr_open: 52706963
    vm.swappiness: 0
    vm.overcommit_memory: 1
    vm.panic_on_oom: 0