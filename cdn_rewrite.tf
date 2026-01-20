resource "kubernetes_manifest" "middleware_cdn_rewrite" {
  manifest = yamldecode(local.middleware_cdn_rewrite_manifest)
  field_manager {
    force_conflicts = true
  }
}

locals {
  middleware_cdn_rewrite_manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace:  "${kubernetes_namespace_v1.this.metadata[0].name}"
  name: "${local.middleware_cdn_rewrite_name}"
spec:
  plugin:
    rewrite-body:
      lastModified: true
      rewrites:
        - regex: "${local.uploads_url_regex}"
          replacement: "https://${local.s3_cdn_wordpresss_uploads_path}/"
        - regex: "${local.uploads_url_json_regex}"
          replacement: "https://${local.s3_cdn_wordpresss_uploads_path}/"
      logLevel: 0
      monitoring:
        methods:
          - GET
          - POST
        types:
          - text/html
          - application/json
          - application/javascript
          - text/javascript
          - text/css   
EOF
}