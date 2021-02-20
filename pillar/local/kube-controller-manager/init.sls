kube-controller-manager:
  bind: 0.0.0.0
  terminatedPodGcThreshold: 12500
  nodeMonitorPeriod: Fast
  nodeStatusUpdate: Fast
  log:
    logLevel: 2