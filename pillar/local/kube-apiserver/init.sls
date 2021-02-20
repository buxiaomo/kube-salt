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
  tls_cipher_suites:
    - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
    - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
    - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    - TLS_RSA_WITH_AES_256_GCM_SHA384
    - TLS_RSA_WITH_AES_128_GCM_SHA256
  log:
    logLevel: 2