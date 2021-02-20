kube-apiserver:
  bind: 0.0.0.0
  encryption: Tsg7sO4Ki/W3s9bfwGfTi8ECcp+/3uDedQMq6rLQTIY= # head -c 32 /dev/urandom | base64
  enable_admission_plugins:
    - AlwaysPullImages
    - ServiceAccount
    - NamespaceLifecycle
    - NodeRestriction
    - LimitRanger
    - PersistentVolumeClaimResize
    - DefaultStorageClass
    - DefaultTolerationSeconds
    - MutatingAdmissionWebhook
    - ValidatingAdmissionWebhook
    - ResourceQuota
    - Priority
  authorization_modes:
    - Node
    - RBAC
  kubelet_preferred_address_types:
    - InternalIP
    - ExternalIP
    - Hostname
  log:
    logLevel: 2