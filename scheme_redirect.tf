resource "kubernetes_manifest" "schema-redirect" {
  manifest = yamldecode(local.middleware-schema-redirect-manifest)
}

locals {
  middleware-schema-redirect-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace:  "${kubernetes_namespace.this.metadata[0].name}"
  name: "${local.middleware-schema-redirect-name}"
spec:
  redirectScheme:
    scheme: https
    permanent: true
EOF
}