resource "kubernetes_manifest" "middleware_wpadmin_ipallowlist" {
  manifest = yamldecode(wpadmin_ipallowlist_middleware_manifest)
  field_manager {
    force_conflicts = true
  }
}

locals {
  wpadmin_ipallowlist_middleware_manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace: kubernetes_namespace_v1.this.metadata[0].name
  name: ${local.middleware_wpadmin_ipallowlist_name}
spec:
  ipAllowList:
    sourceRange:
    %{for ip in local.ip_allowlist}
    - ${ip}
    %{endfor}
EOF
}