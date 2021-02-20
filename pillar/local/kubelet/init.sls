kubelet:
  bind: 0.0.0.0
  pod_infra_container_image: registry.aliyuncs.com/google_containers/pause:3.2
  image_pull_progress_deadline: 2m
  log:
    logLevel: 2