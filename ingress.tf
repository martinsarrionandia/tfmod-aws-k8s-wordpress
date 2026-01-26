resource "kubernetes_manifest" "this_ingressroute_wordpress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      annotations = {
        "external-dns.alpha.kubernetes.io/hostname" = local.fqdn
        "external-dns.alpha.kubernetes.io/target"   = var.public_ip
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-wordpress"
      namespace = kubernetes_namespace_v1.this.metadata[0].name
    }

    spec = {
      entryPoints = ["websecure"]

      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${local.fqdn}`) && PathPrefix(`/`)"
          priority = 10

          middlewares = concat(
            [
              {
                name      = local.middleware_cache_control_name
                namespace = kubernetes_namespace_v1.this.metadata[0].name
              },
              {
                name      = local.middleware_cdn_rewrite_name
                namespace = kubernetes_namespace_v1.this.metadata[0].name
              }
            ],
            var.additional_middlewares_maps
          )

          services = [
            {
              name = "${var.release_name}-${var.release_chart}"
              port = 80
            }
          ]
        }
      ]

      tls = {
        secretName = "${var.release_name}-${var.cluster_issuer}"
      }
    }
  }
}


resource "kubernetes_manifest" "this_ingressroute_wpadmin" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      annotations = {
        "external-dns.alpha.kubernetes.io/controller" = "ignore"
      }
      labels = {
        app = var.release_chart
      }
      name      = "${var.release_name}-wpadmin"
      namespace = kubernetes_namespace_v1.this.metadata[0].name
    }

    spec = {
      entryPoints = ["websecure"]

      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${local.fqdn}`) && PathPrefix(`/wp-admin/`)"
          priority = 20

          middlewares = concat(
            [
              {
                name      = local.middleware_wpadmin_ipallowlist_name
                namespace = kubernetes_namespace_v1.this.metadata[0].name
              }
            ]
          )

          services = [
            {
              name = "${var.release_name}-${var.release_chart}"
              port = 80
            }
          ]

        }
      ]
      tls = {
        secretName = "${var.release_name}-${var.cluster_issuer}"
      }
    }
  }
}


resource "kubernetes_manifest" "this_ingressroute_ajax" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      annotations = {
        "external-dns.alpha.kubernetes.io/controller" = "ignore"
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
          match    = "Host(`${local.fqdn}`) && !ClientIP(`${var.public_ip}`) && Path(`/wp-admin/admin-ajax.php`)"
          priority = 30

          middlewares = concat(
            [
              {
                name      = local.middleware_cdn_rewrite_name
                namespace = kubernetes_namespace_v1.this.metadata[0].name
              }
            ],
          var.additional_middlewares_maps)

          services = [
            {
              name = "${var.release_name}-${var.release_chart}"
              port = 80
            }
          ]

        }
      ]
      tls = {
        secretName = "${var.release_name}-${var.cluster_issuer}"
      }
    }
  }
}

