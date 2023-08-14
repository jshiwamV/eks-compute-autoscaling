resource "helm_release" "cluster-autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = true

  repository = "https://kubernetes.github.io/autoscaler/"
  chart      = "cluster-autoscaler"
  version    = "9.29.1"

  wait = true
  values = [<<-EOT
autoDiscovery:
  clusterName: ${var.cluster_name}

awsRegion: ${var.region}


resources:
  limits:
    cpu: 0.5
    memory: 1000Mi
  requests:
    cpu: 0.1
    memory: 500Mi

rbac:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${var.cluster_autoscaler_irsa_arn}
    name: ${var.cluster_autoscaler_irsa_name}
EOT
  ]
}


resource "helm_release" "kube-test-container" {
  name             = "kube-test-container"
  namespace        = "kube-test-container"
  create_namespace = true

  repository = "https://raw.githubusercontent.com/sverrirab/kube-test-container/master/helm/charts/"
  chart      = "kube-test-container"
  version    = "1.0.0"

  wait = true
  values = [<<-EOT
replicaCount: ${var.replica_count}
image:
  repository: sverrirab/kube-test-container
  tag: v1.0
  pullPolicy: IfNotPresent
service:
  name: kube-test-container
  type: LoadBalancer
  externalPort: 80
  internalPort: 8000
resources:
  limits:
    cpu: 0.1
    memory: 250Mi
  requests:
    cpu: 0.05
    memory: 250Mi
EOT
  ]
}


