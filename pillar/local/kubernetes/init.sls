kubernetes:
  version: 1.20.2
  location: /etc/kubernetes

  master_run_pod: false
  PodCIDR: 10.244.0.0/16
  SvcCIDR: 10.96.0.0/12
  SvcIP: 10.96.0.1
  DNSIP: 10.96.0.2
  NodePortRange: 30000-32767
  ClusterDomain: cluster.local