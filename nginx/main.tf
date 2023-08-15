resource "helm_release" "nginx" {
  name             = "nginx-1"
  namespace        = "nginx"
  create_namespace = true

  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "nginx"
  version    = "15.1.2"

  wait = true
  values = [<<-EOT
replicaCount: 50
resources:
  limits:
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 64Mi
EOT
]
}
