data "helm_template" "wordpress" {
  namespace  = kubernetes_namespace.this.metadata.0.name
  name       = var.release-name
  repository = var.release-repo
  chart      = var.release-chart

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "networkPolicy.enabled"
    value = "false"
  }

  set {
    name = "mariadb.networkPolicy.enabled"
    value = "false"
  }

  set {
    name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = yamlencode(local.fqdn)
    type  = "string"
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.wordpress_root.metadata.0.name
  }

  set {
    name  = "mariadb.primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.wordpress_maria.metadata.0.name
  }

  set {
    name = "extraVolumes"
    value = yamlencode([
      {
        "name" : "uploads",
        "persistentVolumeClaim" : {
          "claimName" : "${kubernetes_persistent_volume_claim.wordpress_uploads.metadata.0.name}"
        }
      }
    ])
  }

  set {
    name = "extraVolumeMounts"
    value = yamlencode([
      {
        "name" : "uploads",
        "mountPath" : "/bitnami/wordpress/wp-content/uploads"
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

  #set {
  #  name  = "containerSecurityContext.seLinuxOptions"
  #  value = yamlencode(local.selinux-options)
  #}

  values = local.wordpress-helm-values
  
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