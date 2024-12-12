resource "kubernetes_manifest" "this-ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "cert-manager.io/cluster-issuer"                   = var.cluster-issuer
        "traefik.ingress.kubernetes.io/router.middlewares" = local.middlewares
      }
      labels = {
        app = var.release-chart
      }
      name      = var.release-name
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
                    name = "${var.release-name}-${var.release-chart}"
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