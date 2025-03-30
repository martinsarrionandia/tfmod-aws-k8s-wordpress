resource "kubernetes_manifest" "redirect-scheme" {
  manifest = yamldecode(local.middleware-redirect-scheme-manifest)
}

locals {
  middleware-redirect-scheme-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace:  "${kubernetes_namespace.this.metadata[0].name}"
  name: "${local.middleware-scheme-redirect-name}"
spec:
  redirectScheme:
    scheme: https
    permanent: true
EOF
}