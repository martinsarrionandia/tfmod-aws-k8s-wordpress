resource "kubernetes_manifest" "this_ingress_wordpress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "external-dns.alpha.kubernetes.io/hostname"        = local.fqdn
        "external-dns.alpha.kubernetes.io/target"          = var.public_ip
        "cert-manager.io/cluster_issuer"                   = var.cluster_issuer
        "traefik.ingress.kubernetes.io/router.middlewares" = local.wordpress_middlewares
        "traefik.ingress.kubernetes.io/router.priority"    = "10"
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-wordpress"
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


resource "kubernetes_manifest" "this_ingress_wpadmin" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "cert-manager.io/cluster_issuer"                   = var.cluster_issuer
        "traefik.ingress.kubernetes.io/router.middlewares" = local.wpadmin_middlewares
        "traefik.ingress.kubernetes.io/router.priority"    = "20"
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-wpadmin"
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
                path     = "/wp-admin/"
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

resource "kubernetes_manifest" "this_ingress_ajax" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "cert-manager.io/cluster_issuer"                   = var.cluster_issuer
        "traefik.ingress.kubernetes.io/router.priority"    = "30"
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-ajax"
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
                path     = "/wp-admin/admin-ajax.php"
                pathType = "Exact"
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