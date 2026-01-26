resource "kubernetes_manifest" "this_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${var.release_name}-cert"
      namespace = kubernetes_namespace_v1.this.metadata[0].name
    }
    spec = {
      # Matches the secretName used in your IngressRoute: "${var.release_name}-${var.cluster_issuer}"
      secretName = "${var.release_name}-${var.cluster_issuer}"
      commonName = local.fqdn
      dnsNames   = [local.fqdn]
      issuerRef = {
        name = var.cluster_issuer
        kind = "ClusterIssuer"
      }
    }
  }
}
