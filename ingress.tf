resource "kubernetes_manifest" "this" {
  manifest = yamldecode (local.ingress-route-manifest2)
}

locals {

ingress-route-manifest = <<EOF
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ${var.release-name}
  namespace: ${var.release-chart}
  annotations:
    cert-manager.io/cluster-issuer: "${var.cluster-issuer}"
    external-dns.alpha.kubernetes.io/hostname: "${local.fqdn}"
    external-dns.alpha.kubernetes.io/target: "${var.public-ip}"
spec:
  entryPoints:
    - http
  #  - websecure
  routes:
  - kind: Rule
    match: Host(${local.fqdn}) && PathPrefix(`/`)
    priority: 10
    #middlewares:
    #- name: "${local.middleware-cdn-rewrite-name}"
    #  namespace: "${kubernetes_namespace.this.metadata.0.name}"
    services:
    - kind: Service
      name: "${helm_release.wordpress.metadata.0.name}-${helm_release.wordpress.metadata.0.chart}"
      namespace: "${kubernetes_namespace.this.metadata.0.name}"
      passHostHeader: true
      port: 80 
      responseForwarding:
        flushInterval: 1ms
      scheme: https
      serversTransport: transport
  tls:
    secretName: "${var.cluster-issuer}"
    #options:
    #  name: 
    #  namespace: default
    #certResolver: "${var.cluster-issuer}"
    domains:
    - main: "${local.fqdn}"

EOF

ingress-route-manifest2 = <<EOF
apiVersion: traefik.containo.us/v1alpha1
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
    - http
  #  - websecure
  routes:
  - kind: Rule
    match: Host(`photobooth.wales`) && PathPrefix(`/`)
    priority: 10
    #middlewares:
    #- name: "${local.middleware-cdn-rewrite-name}"
    #  namespace: "${kubernetes_namespace.this.metadata.0.name}"
    services:
    - kind: Service
      name: mojobooth-wordpress
      namespace: mojobooth
      passHostHeader: true
      port: 80
      responseForwarding:
        flushInterval: 1ms
      scheme: https
      serversTransport: transport
  tls:
    secretName: lets-encrypt
    #options:
    #  name:
    #  namespace: default
    #certResolver: "${var.cluster-issuer}"
    domains:
    - main: mojobooth.wales

EOF
}