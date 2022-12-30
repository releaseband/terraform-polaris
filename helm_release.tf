
resource "helm_release" "polaris" {
  name        = "polaris"
  namespace   = kubernetes_namespace.namespace.metadata[0].name
  repository  = "https://charts.fairwinds.com/stable"
  version     = "5.4.2"
  chart       = "polaris"
  timeout     = 180
  max_history = 10
  values = [
    <<-EOF
config:
  checks:
    # reliability
    deploymentMissingReplicas: ignore
    priorityClassNotSet: ignore
    tagNotSpecified: warning
    pullPolicyNotAlways: warning
    readinessProbeMissing: warning
    livenessProbeMissing: warning
    metadataAndNameMismatched: ignore
    pdbDisruptionsIsZero: warning
    missingPodDisruptionBudget: ignore

    # efficiency
    cpuRequestsMissing: warning
    cpuLimitsMissing: warning
    memoryRequestsMissing: warning
    memoryLimitsMissing: warning
    # security
    hostIPCSet: danger
    hostPIDSet: danger
    notReadOnlyRootFilesystem: warning
    privilegeEscalationAllowed: danger
    runAsRootAllowed: danger
    runAsPrivileged: danger
    dangerousCapabilities: danger
    insecureCapabilities: warning
    hostNetworkSet: warning
    hostPortSet: warning
    tlsSettingsMissing: ignore
    imageRegistry: danger

  customChecks:
    imageRegistry:
      successMessage: Image comes from allowed registries
      failureMessage: Image should not be from disallowed registry
      category: Security
      target: Container
      schema:
        '$schema': http://json-schema.org/draft-07/schema
        type: object
        properties:
          image:
            type: string
            oneOf:
            - pattern: ${var.allowed_container_registry}


  exemptions:
    - containerNames:
        - linkerd-init
      rules:
        - dangerousCapabilities
        - runAsRootAllowed
        - privilegeEscalationAllowed
    - containerNames:
        - timescale-main-backup-pod-init
      rules:
        - tagNotSpecified
    - containerNames:
        - timescale-main-timescaledb-patch-patroni-config
      rules:
        - imageRegistry
        - privilegeEscalationAllowed
        - runAsRootAllowed
    - controllerNames:
        - hasura
      rules:
        - livenessProbeMissing
    - controllerNames:
        - timescale-main-timescaledb
      containerNames:
        - pgbackrest
        - postgres-exporter
        - timescaledb
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
    - namespace: ingress
      controllerNames:
        - default-ingress-nginx-controller
        - private-ingress-nginx-controller
      containerNames:
        - controller
      rules:
        - notReadOnlyRootFilesystem
    - namespace: kube-system
      controllerNames:
        - aws-node
      rules:
        - hostNetworkSet
        - runAsPrivileged
        - privilegeEscalationAllowed
        - runAsRootAllowed
        - insecureCapabilities
        - notReadOnlyRootFilesystem
        - dangerousCapabilities
        - cpuLimitsMissing
        - memoryLimitsMissing
        - memoryRequestsMissing
        - hostPortSet
        - imageRegistry
    - namespace: kube-system
      controllerNames:
        - ebs-csi-node
      rules:
        - runAsPrivileged
        - privilegeEscalationAllowed
        - livenessProbeMissing
        - readinessProbeMissing
        - runAsRootAllowed
        - notReadOnlyRootFilesystem
        - hostPortSet
    - namespace: kube-system
      controllerNames:
        - kube-proxy
      rules:
        - privilegeEscalationAllowed
        - insecureCapabilities
        - pullPolicyNotAlways
        - hostNetworkSet
        - runAsPrivileged
        - cpuLimitsMissing
        - livenessProbeMissing
        - readinessProbeMissing
        - notReadOnlyRootFilesystem
        - memoryRequestsMissing
        - memoryLimitsMissing
        - runAsRootAllowed
        - imageRegistry
    - namespace: kube-system
      controllerNames:
        -  termination-handler-aws-node-termination-handler
      rules:
        - privilegeEscalationAllowed
        - insecureCapabilities
        - pullPolicyNotAlways
        - hostNetworkSet
        - livenessProbeMissing
        - readinessProbeMissing
    - namespace: kube-system
      controllerNames:
        -   cluster-autoscaler-aws-cluster-autoscaler
      rules:
        - notReadOnlyRootFilesystem
        - readinessProbeMissing
    - namespace: kube-system
      controllerNames:
        -  coredns
      rules:
        - pullPolicyNotAlways
        - runAsRootAllowed
        - cpuLimitsMissing
        - imageRegistry
    - namespace: kube-system
      controllerNames:
        -  ebs-csi-controller
      rules:
        - runAsRootAllowed
        - readinessProbeMissing
        - livenessProbeMissing
    - namespace: metabase
      controllerNames:
        -  postgres
      rules:
        - runAsRootAllowed
        - readinessProbeMissing
        - livenessProbeMissing
    - namespace: monitoring
      controllerNames:
        -  promtail
      rules:
        - runAsRootAllowed
        - livenessProbeMissing
    - namespace: monitoring
      containerNames:
        - create
      rules:
        - privilegeEscalationAllowed
    - namespace: monitoring
      containerNames:
        - patch
      rules:
        - privilegeEscalationAllowed
    - namespace: monitoring
      controllerNames:
        -  monitoring-prometheus-node-exporter
      rules:
        - hostPIDSet
        - hostNetworkSet
        - hostPortSet
    - namespace: monitoring
      controllerNames:
        -  monitoring-grafana
      containerNames:
        - init-chown-data
      rules:
        - runAsRootAllowed
    - namespace: monitoring
      controllerNames:
        -  monitoring-grafana
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
    - namespace: monitoring
      controllerNames:
        -  monitoring-kube-prometheus-operator
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
      controllerNames:
        -  prometheus-monitoring-kube-prometheus-prometheus
      rules:
        - privilegeEscalationAllowed
        - insecureCapabilities
        - pullPolicyNotAlways
        - hostNetworkSet
        - runAsPrivileged
        - cpuLimitsMissing
        - livenessProbeMissing
        - readinessProbeMissing
        - notReadOnlyRootFilesystem
        - memoryRequestsMissing
        - memoryLimitsMissing
        - runAsRootAllowed
        - imageRegistry    
    - namespace: monitoring
      controllerNames:
        -  thanos-store
      containerNames:
        - init
      rules:
        - runAsRootAllowed
    - namespace: monitoring
      controllerNames:
        -  thanos-compact
      containerNames:
        - init
      rules:
        - runAsRootAllowed
    - namespace: tigera-operator
      controllerNames:
        -  tigera-operator
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
        - hostNetworkSet
    - namespace: vault
      controllerNames:
        -  vault
      rules:
        - livenessProbeMissing
    - namespace: boundary
      controllerNames:
        -  boundary
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
    - namespace: boundary
      controllerNames:
        -  postgres
      rules:
        - livenessProbeMissing
        - readinessProbeMissing
    - namespace: boundary
      controllerNames:
        -  postgres
      containerNames:
        - init
      rules:
        - runAsRootAllowed
    - namespace: calico-system
      rules:
        - privilegeEscalationAllowed
        - insecureCapabilities
        - pullPolicyNotAlways
        - hostNetworkSet
        - runAsPrivileged
        - cpuLimitsMissing
        - livenessProbeMissing
        - readinessProbeMissing
        - notReadOnlyRootFilesystem
        - memoryRequestsMissing
        - memoryLimitsMissing
        - runAsRootAllowed
        - imageRegistry
    - namespace: calico-apiserver
      rules:
        - privilegeEscalationAllowed
        - insecureCapabilities
        - pullPolicyNotAlways
        - hostNetworkSet
        - runAsPrivileged
        - cpuLimitsMissing
        - livenessProbeMissing
        - readinessProbeMissing
        - notReadOnlyRootFilesystem
        - memoryRequestsMissing
        - memoryLimitsMissing
        - runAsRootAllowed
        - imageRegistry
image:
  repository: ${var.polaris_image_repository}
  tag: ${var.polaris_image_tag}
  pullPolicy: Always
webhook:
  replicas: 2
  enable: true
  failurePolicy: Ignore
  matchPolicy: Exact
  rules: []
  resources:
    requests:
      cpu: 100m
      memory: 30Mi
    limits:
      cpu: 150m
      memory: 512Mi
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - polaris
          - key: component
            operator: In
            values:
            - webhook
        topologyKey: "kubernetes.io/hostname"
dashboard:
  replicas: 1
  resources:
    requests:
      cpu: 10m
      memory: 20Mi
    limits:
      cpu: 150m
      memory: 512Mi
    EOF
  ]
}