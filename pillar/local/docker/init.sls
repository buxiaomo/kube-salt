docker:
  daemon: 
    data-root: /var/lib/docker
    exec-opts:
      - "native.cgroupdriver=systemd"
    registry-mirrors:
      - "https://i3jtbyvy.mirror.aliyuncs.com"
    storage-driver: "overlay2"
    storage-opts: 
      - "overlay2.override_kernel_check=true"
    log-driver: "json-file"
    log-opts: 
      max-size: "100m"
      max-file: "5"
    max-concurrent-downloads: 20
    max-concurrent-uploads: 10
    live-restore: true
    userland-proxy: false
    experimental: false
    icc: false
    debug: false
    default-ulimits:
      nofile:
        Name: nofile
        Hard: 655360
        Soft: 655360