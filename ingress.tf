resource "kubernetes_manifest" "this_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "external-dns.alpha.kubernetes.io/hostname"        = local.fqdn
        "external-dns.alpha.kubernetes.io/target"          = var.public_ip
        "cert-manager.io/cluster_issuer"                   = var.cluster_issuer
        "traefik.ingress.kubernetes.io/router.middlewares" = local.middlewares
      }
      labels = {
        app = var.release_chart
      }
      name      = var.release_name
      namespace = kubernetes_namespace_v1.this.metadata[0].name
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
                    name = "${var.release_name}-${var.release_chart}"
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
          secretName = var.cluster_issuer
        },
      ]
    }
  }
}