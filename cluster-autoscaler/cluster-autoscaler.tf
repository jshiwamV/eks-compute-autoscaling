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


rbac:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${var.cluster_autoscaler_irsa_arn}
    name: ${var.cluster_autoscaler_irsa_name}
EOT
  ]
}
