resource "kubernetes_manifest" "this_ingress" {
  manifest = yamldecode (local.ingress-route-manifest)
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
    external-dns.alpha.kubernetes.io/hostname: "${local.fqdn}"
    external-dns.alpha.kubernetes.io/target: "${var.public-ip}"
spec:
  entryPoints:
    - web
    - websecure
  routes:
  - kind: Rule
    match: Host(`${local.fqdn}`) && PathPrefix(`/`)
    priority: 10
    #middlewares:
    #- name: "${local.middleware-cdn-rewrite-name}"
    #  namespace: "${kubernetes_namespace.this.metadata.0.name}"
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
    secretName: ${local.fqdn}-secret
    #options:
    #  name:
    #  namespace: default
#    certResolver: "${var.cluster-issuer}"
    domains:
    - main: ${local.fqdn}

EOF
}