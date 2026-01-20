resource "helm_release" "wordpress" {
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  name       = var.release-name
  repository = var.release-repo
  chart      = var.release-chart
  version    = var.release-version == "latest" ? null : var.release-version
  values     = [local.wordpress-helm-values]

  set = concat([{
    name  = "replicaCount"
    value = "1"
    },
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = yamlencode(local.fqdn)
      type  = "string"
    },
    {
      name  = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/target"
      value = yamlencode(var.public-ip)
      type  = "string"
    },
    {
      name  = "networkPolicy.enabled"
      value = "false"
    },
    {
      name  = "mariadb.networkPolicy.enabled"
      value = "false"
    },
    {
      name  = "persistence.existingClaim"
      value = kubernetes_persistent_volume_claim_v1.wordpress_root.metadata[0].name
    },
    {
      name  = "mariadb.primary.persistence.existingClaim"
      value = kubernetes_persistent_volume_claim_v1.wordpress_maria.metadata[0].name
    },
    {
      name = "extraVolumes"
      value = yamlencode([
        {
          "name" : "uploads",
          "persistentVolumeClaim" : {
            "claimName" : kubernetes_persistent_volume_claim_v1.wordpress_uploads.metadata[0].name
          }
        }
      ])
    },
    {
      name = "extraVolumeMounts"
      value = var.initial-setup == true ? "" : yamlencode([
        {
          "name" : "uploads",
          "mountPath" : "/bitnami/wordpress/${var.wordpress-uploads-dir}"
        }
      ])
    },
    {
      name  = "volumePermissions.enabled"
      value = var.initial-setup
    },
    {
      name  = "wordpressUsername"
      value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["wordpressUsername"]
    },
    {
      name  = "wordpressPassword"
      value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["wordpressPassword"]
    },
    {
      name  = "mariadb.auth.rootPassword"
      value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["mariadb.auth.rootPassword"]
    },
    {
      name  = "mariadb.auth.password"
      value = jsondecode(data.aws_secretsmanager_secret_version.wordpress_current.secret_string)["mariadb.auth.password"]
    },
    {
      name  = "image.debug"
      value = var.debug
    },
    {
      name  = "diagnosticMode.enabled"
      value = var.diagnostic
    }],
    var.docker_legacy_repo ? [
      {
        name  = "volumePermissions.image.repository"
        value = "bitnamilegacy/os-shell"
      },
      {
        name  = "mariadb.image.repository"
        value = "bitnamilegacy/mariadb"
      },
      {
        name  = "image.repository"
        value = "bitnamilegacy/wordpress"
      },
  ] : [])

}

locals {

  wordpress-helm-values = <<EOF
containerSecurityContext:
  seLinuxOptions:
    level: ${local.selinux-level}
volumePermissions:
  image:
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
wordpressExtraConfigContent: |
  define('WP_PROXY_HOST', '${split(":", var.http_proxy_address)[0]}');
  define('WP_PROXY_PORT', '${split(":", var.http_proxy_address)[1]}');
  define('WP_PROXY_BYPASS_HOSTS', 'localhost, 127.0.0.1, *.svc, *.cluster.local, 10.*, 172.16.*, 192.168.*, 172.16.*');

EOF
}