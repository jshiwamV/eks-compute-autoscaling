locals {
  node_group_id = element(split(":", var.eks_managed_node_group_id), length(split(":", var.eks_managed_node_group_id)) - 1)
}


resource "helm_release" "karpenter-crd" {
  name             = "karpenter-crd"
  namespace        = "kube-system"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter/"
  chart      = "karpenter-crd"
  version    = "v0.27.3"
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter/"
  chart      = "karpenter"
  version    = "v0.27.3"

  wait = true
  values = [<<-EOT
serviceAccount:
  name: "karpenter"
  annotations:
    eks.amazonaws.com/role-arn: ${var.karpenter_irsa_arn}

replicas: 1

serviceMonitor:
  enabled: true

settings:
  aws:
    clusterName: ${var.cluster_name}
    defaultInstanceProfile: ${var.karpenter_instance_profile_name}
    tags:
      karpenter.sh/discovery: ${var.cluster_name}

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: karpenter.sh/provisioner-name
              operator: DoesNotExist
        - matchExpressions:
            - key: eks.amazonaws.com/nodegroup
              operator: In
              values:
                - ${local.node_group_id}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
EOT
  ]
  depends_on = [helm_release.karpenter-crd]
}

# Karpenter Provider Manifest
resource "kubectl_manifest" "provider" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1alpha1"
    kind       = "AWSNodeTemplate"

    metadata = {
      name = "karpenter-provider"
    }

    spec = {
      subnetSelector = {
        "karpenter.sh/discovery" = var.cluster_name
      }
      securityGroupSelector = {
        "karpenter.sh/discovery" = var.cluster_name
      }
      tags = {
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
  })
  depends_on = [helm_release.karpenter]
}

# Karpenter Provisioner Manifest
resource "kubectl_manifest" "provisioner" {

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"

    metadata = {
      name = "karpenter"
    }

    spec = {
      consolidation = {
        enabled = true
      }

      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
        },
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values   = ["c", "m", "r"]
        },
        {
          key      = "karpenter.k8s.aws/instance-generation"
          operator = "In"
          values   = ["6", "7"]
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        },
      ]

      limits = {
        resources = {
          cpu    = "10"
          memory = "30Gi"
        }
      }

      providerRef = {
        name = "karpenter-provider"
      }
    }

  })

  depends_on = [kubectl_manifest.provider]
}
