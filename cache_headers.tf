resource "kubernetes_manifest" "middleware-cache-control" {
  manifest = yamldecode(local.middleware-cache-control)
  field_manager {
    force_conflicts = true
  }
}

locals {
  middleware-cache-control = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace: "${kubernetes_namespace.this.metadata[0].name}"
  name: "${local.middleware-cache-control-name}"
spec:
  headers:
    customResponseHeaders:
      Cache-Control: public, max-age=2592000, immutable

EOF
}