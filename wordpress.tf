resource "helm_release" "wordpress" {
  namespace  = kubernetes_namespace.this.metadata[0].name
  name       = var.release-name
  repository = var.release-repo
  chart      = var.release-chart
  values     = [local.wordpress-helm-values]

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "image.tag"
    value = var.image-tag
  }

  set {
    name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = yamlencode(local.fqdn)
    type  = "string"
  }

  set {
    name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/target"
    value = yamlencode(var.public-ip)
    type  = "string"
  }

  set {
    name  = "networkPolicy.enabled"
    value = "false"
  }

  set {
    name  = "mariadb.networkPolicy.enabled"
    value = "false"
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.wordpress_root.metadata[0].name
  }

  set {
    name  = "mariadb.primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.wordpress_maria.metadata[0].name
  }

  set {
    name = "extraVolumes"
    value = yamlencode([
      {
        "name" : "uploads",
        "persistentVolumeClaim" : {
          "claimName" : kubernetes_persistent_volume_claim.wordpress_uploads.metadata[0].name
        }
      }
    ])
  }

  set {
    name = "extraVolumeMounts"
    value = yamlencode([
      {
        "name" : "uploads",
        "mountPath" : "/bitnami/wordpress/${var.wordpress-uploads-dir}"
      }
    ])
  }

  set {
    name  = "volumePermissions.enabled"
    value = var.initial-setup
  }

  set {
    name  = "containerSecurityContext.enabled"
    value = "true"
  }

  set {
    name  = "wordpressUsername"
    value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["wordpressUsername"]
  }

  set {
    name  = "wordpressPassword"
    value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["wordpressPassword"]
  }

  set {
    name  = "mariadb.auth.rootPassword"
    value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["mariadb.auth.rootPassword"]
  }

  set {
    name  = "mariadb.auth.password"
    value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["mariadb.auth.password"]
  }
}

locals {

  wordpress-helm-values = <<EOF
containerSecurityContext:
  seLinuxOptions:
    level: ${local.selinux-level}
resources:
  requests:
    cpu: 25m
mariadb:
  primary:
    resources:
      requests:
        cpu: 25m

EOF
}