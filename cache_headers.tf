resource "kubernetes_manifest" "middleware_cache_control" {
  manifest = yamldecode(local.middleware_cache_control_manifest)
  field_manager {
    force_conflicts = true
  }
}

locals {
  middleware_cache_control_manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace: "${kubernetes_namespace_v1.this.metadata[0].name}"
  name: "${local.middleware_cache_control_name}"
spec:
  headers:
    customResponseHeaders:
      Cache-Control: public, max-age=2592000, immutable

EOF
}