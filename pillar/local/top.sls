local:
  '*':
    - common

  'roles:etcd':
    - match: grain_pcre
    - etcd

  'roles:(kube-master|kube-worker)':
    - match: grain_pcre
    - docker
    - kubernetes

  'roles:kube-master':
    - match: grain_pcre
    - kube-apiserver
    - kube-scheduler
    - kube-controller-manager
    - kube-proxy
    - docker
    - kubelet
    - kube-addon

  'roles:kube-worker':
    - match: grain_pcre
    - kube-proxy
    - docker
    - kubelet