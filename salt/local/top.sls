local:
  '*':
    - common

  'roles:ca':
    - match: grain
    - ca

  'roles:kube-etcd':
    - match: grain
    - kube-etcd

  'roles:kube-master':
    - match: grain
    - kube-master

  'roles:kube-worker':
    - match: grain
    - kube-worker