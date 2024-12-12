resource "kubernetes_manifest" "this-ingress-route" {
  manifest = yamldecode(local.ingress-route-manifest)
  count    = 0
}

locals {

  ingress-route-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ${var.release-name}
  namespace: "${kubernetes_namespace.this.metadata.0.name}"
  annotations:
    cert-manager.io/cluster-issuer: "${var.cluster-issuer}"
spec:
  entryPoints:
    - web
    - websecure
  routes:
    - kind: Rule
      match: Host(`${local.fqdn}`) && PathPrefix(`/`)
      priority: 10
      middlewares:
        - name: "${local.middleware-cdn-rewrite-name}"
          namespace: "${kubernetes_namespace.this.metadata.0.name}"
        %{for middleware in var.additional-middlewares-map}
        - name: ${middleware.name}@kubernetescrd
          namespace: ${middleware.namespace}
        %{endfor}
      services:
      - kind: Service
        name: ${var.release-name}-${var.release-chart}
        namespace: ${kubernetes_namespace.this.metadata.0.name}
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
    certResolver: "${var.cluster-issuer}"
    domains:
      - main: ${local.fqdn}

EOF
}