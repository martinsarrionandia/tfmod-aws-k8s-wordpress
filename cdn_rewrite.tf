resource "kubernetes_manifest" "middleware-cdn-rewrite" {
  manifest = yamldecode(local.middleware-cdn-rewrite-manifest)
}

locals {
  middleware-cdn-rewrite-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace:  "${kubernetes_namespace.this.metadata.0.name}"
  name: "${local.middleware-cdn-rewrite-name}"
spec:
  plugin:
    rewrite-body:
      lastModified: true
      rewrites:
        - regex: "https?://${local.fqdn}/${var.wordpress-uploads-dir}"
          replacement: "https://${local.s3-cdn-wordpresss-uploads-path}"
      logLevel: 0
      monitoring:
        methods:
          - GET
        types:
          - text/html

EOF
}