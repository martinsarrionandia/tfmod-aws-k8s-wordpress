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
  count = var.initial-setup == true ? 0 : 1
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
        key      = "app.kubernetes.io/name"
        operator = "In"
        values   = ["sync-uploads"]
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "TCP"
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }

      to {
        namespace_selector {
          match_expressions {
            key      = "kubernetes.io/metadata.name"
            operator = "In"
            values   = ["kube-system"]
          }
          match_labels = {
            name  = "kubernetes.io/metadata.name"
            value = "kube-system"
          }
        }
        pod_selector {
          match_expressions {
            key      = "k8s-app"
            operator = "In"
            values   = ["kube-dns"]
          }
          match_labels = {
            name  = "k8s-app"
            value = "kube-dns"
          }
        }
      }
    }
    egress {
      ports {
        port     = "443"
        protocol = "TCP"
      }

      dynamic "to" {
        for_each = data.aws_prefix_list.s3_prefix_list.cidr_blocks
        content {
          ip_block {
            cidr = to.value
          }
        }

      }
    }
    ingress {} # single empty rule to allow all ingress traffic
  }
}