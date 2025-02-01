resource "kubernetes_manifest" "wordpress_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_wordpress.yaml",
    {
      release-name = var.release-name,
      namespace    = kubernetes_namespace.this.metadata[0].name
  }))
}

resource "kubernetes_manifest" "mariadb_network_policy" {
  manifest = yamldecode(templatefile("${path.module}/templates/network_policy_mariadb.yaml",
    {
      release-name = var.release-name,
      namespace    = kubernetes_namespace.this.metadata[0].name
  }))
}



resource "kubernetes_network_policy" "sync_uploads_network_policy" {
  count = 0
  metadata {
    name      = "${var.release-name}-sync-uploads"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    policy_types = ["Ingress", "Egress"]

    pod_selector {
      match_expressions {
        key      = "app.kubernetes.io/instance"
        operator = "In"
        values   = ["${var.release-name}"]
      }
      match_expressions {
        key      = "app.kubernetes.io/name:"
        operator = "In"
        values   = ["sync-uploads"]
      }
    }

    egress {
      ports {
        port     = "http"
        protocol = "TCP"
      }
      ports {
        port     = "8125"
        protocol = "UDP"
      }

      to {
        ip_block {
          cidr = "10.0.0.0/8"
        }
      }
    }

    ingress {} # single empty rule to allow all egress traffic
  }
}