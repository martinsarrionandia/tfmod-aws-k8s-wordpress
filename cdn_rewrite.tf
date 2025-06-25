resource "kubernetes_manifest" "middleware-cdn-rewrite" {
  manifest = yamldecode(local.middleware-cdn-rewrite-manifest)
  field_manager {
    force_conflicts = true
  }
}

locals {
  middleware-cdn-rewrite-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace:  "${kubernetes_namespace.this.metadata[0].name}"
  name: "${local.middleware-cdn-rewrite-name}"
spec:
  plugin:
    rewrite-body:
      lastModified: true
      rewrites:
        - regex: "${local.uploads_url_regex}"
          replacement: "https://${local.s3-cdn-wordpresss-uploads-path}/"
        - regex: "${local.uploads_url_json_regex}"
          replacement: "https://${local.s3-cdn-wordpresss-uploads-path}/"
      logLevel: 0
      monitoring:
        methods:
          - GET
        types:
          - text/html
          - application/json
          - application/javascript
          - text/javascript
EOF
}