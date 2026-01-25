resource "kubernetes_manifest" "this_ingress_wordpress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "external-dns.alpha.kubernetes.io/hostname"        = local.fqdn
        "external-dns.alpha.kubernetes.io/target"          = var.public_ip
        "cert-manager.io/cluster-issuer"                   = var.cluster_issuer
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
          secretName = "${var.release_name}-${var.cluster_issuer}"
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
        "traefik.ingress.kubernetes.io/router.middlewares" = local.wpadmin_middlewares
        "traefik.ingress.kubernetes.io/router.priority"    = "20"
        "external-dns.alpha.kubernetes.io/controller"      = "ignore"
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
    }
  }
}

resource "kubernetes_manifest" "this_ingress_ajax" {
  count = 0
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.middlewares" = local.ajax_middlewares
        "traefik.ingress.kubernetes.io/router.priority"    = "30"
        "external-dns.alpha.kubernetes.io/controller"      = "ignore"
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
    }
  }
}

resource "kubernetes_manifest" "this_ingressroute_ajax" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.priority"    = "30"
        "external-dns.alpha.kubernetes.io/controller"      = "ignore"
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-ajax"
      namespace = kubernetes_namespace_v1.this.metadata[0].name
    }

    spec = {
      entryPoints = ["websecure"]

      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${local.fqdn}`) && Path(`/wp-admin/admin-ajax.php`) && !HeadersRegexp(`User-Agent`, `(WordPress|Elementor)`)"
          priority = 30

          middlewares = local.ajax_middlewares

          services = [
            {
              name = "${var.release_name}-${var.release_chart}"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

