resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "cert-manager.io/cluster-issuer"            = var.cluster-issuer,
        "external-dns.alpha.kubernetes.io/hostname" = local.fqdn,
        "external-dns.alpha.kubernetes.io/target"   = var.public-ip
      }
      labels = {
        app = helm_release.wordpress.metadata.0.chart
      }
      name      = helm_release.wordpress.metadata.0.name
      namespace = kubernetes_namespace.this.metadata.0.name
    }
    spec = {
      rules = [
        {
          host = local.fqdn
          http = {
            paths = [
              {
                backend = {
                  service = {
                    name = "${helm_release.wordpress.metadata.0.name}-${helm_release.wordpress.metadata.0.chart}"
                    port = {
                      number = 80
                    }
                  }
                }
                path     = "/"
                pathType = "Prefix"
              },
            ]
          }
        },
      ]
      tls = [
        {
          hosts = [
            local.fqdn,
          ]
          secretName = var.cluster-issuer
        },
      ]
    }
  }
}