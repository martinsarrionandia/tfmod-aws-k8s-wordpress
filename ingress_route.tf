resource "kubernetes_manifest" "this_ingress_route" {
  manifest = yamldecode(local.ingress_route_manifest)
  count    = 0
}

locals {

  ingress_route_manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ${var.release_name}
  namespace: "${kubernetes_namespace_v1.this.metadata[0].name}"
  annotations:
    cert-manager.io/cluster_issuer: "${var.cluster_issuer}"
spec:
  entryPoints:
    - web
    - websecure
  routes:
    - kind: Rule
      match: Host(`${local.fqdn}`) && PathPrefix(`/`)
      priority: 10
      middlewares:
        - name: "${local.middleware_cdn_rewrite_name}"
          namespace: "${kubernetes_namespace_v1.this.metadata[0].name}"
        %{for middleware in var.additional_middlewares_maps}
        - name: ${middleware.name}@kubernetescrd
          namespace: ${middleware.namespace}
        %{endfor}
      services:
      - kind: Service
        name: ${var.release_name}-${var.release_chart}
        namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
        #passHostHeader: true
        port: 80
        #responseForwarding:
        #  flushInterval: 1ms
        #scheme: https
        #serversTransport: transport
  tls:
    secretName: "${local.fqdn}-secret"
    #options:
    #  name:
    #  namespace: default
    certResolver: "${var.cluster_issuer}"
    domains:
      - main: ${local.fqdn}

EOF
}