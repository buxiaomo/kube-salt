local:
  '*':
    - common

  'roles:etcd':
    - match: grain
    - etcd

  'roles:kube-master':
    - match: grain
    - kube-master

  'roles:kube-worker':
    - match: grain
    - kube-worker