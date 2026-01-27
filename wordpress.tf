resource "helm_release" "wordpress" {
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  name       = var.release_name
  repository = var.release_repo
  chart      = var.release_chart
  version    = var.release_version == "latest" ? null : var.release_version
  values     = [local.wordpress_helm_values]

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
      value = yamlencode(var.public_ip)
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
      value = var.initial_setup == true ? "" : yamlencode([
        {
          "name" : "uploads",
          "mountPath" : "/bitnami/wordpress/${var.wordpress_uploads_dir}"
        }
      ])
    },
    {
      name  = "volumePermissions.enabled"
      value = var.initial_setup
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

  wordpress_helm_values = <<EOF
containerSecurityContext:
  seLinuxOptions:
    level: ${local.selinux_level}
volumePermissions:
  image:
    containerSecurityContext:
      seLinuxOptions:
        level: ${local.selinux_level}
resources:
  requests:
    cpu: 25m
mariadb:
  primary:
    resources:
      requests:
        cpu: 25m
extraEnvVars:
  - name: PHP_UPLOAD_MAX_FILESIZE
    value: "${var.php_max_upload}"
  - name: PHP_POST_MAX_SIZE
    value: "${var.php_max_upload}"
wordpressExtraConfigContent: |

  /* SET HOSTNAME TO AVOID CONTAINER IP AS THE HOSTNAME WHEN RUNNING CRON */

  define('WP_HOME', 'https://${local.fqdn}');
  define('WP_SITEURL', 'https://${local.fqdn}');

  /* FIX LEGACY PLUGINS THAT SERVE HTTP URLS */

  /* Treat as HTTPS if:
    - the request is a Kubernetes probe (kube-probe/... UA), OR
    - the proxy tells us it's HTTPS (X-Forwarded-Proto: https).
  */
  $ua  = $_SERVER['HTTP_USER_AGENT'] ?? '';
  $xfp = $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '';

  if (strpos($ua, 'kube-probe') !== false || strtolower($xfp) === 'https') {
      $_SERVER['HTTPS'] = 'on';
  }
  
  define('WP_PROXY_HOST', '${local.http_proxy_host}');
  define('WP_PROXY_PORT', '${local.http_proxy_port}');
  define('WP_PROXY_BYPASS_HOSTS', 'localhost, 127.0.0.1, *.svc, *.cluster.local, 10.*, 172.16.*, 192.168.*, 172.16.*');

EOF
}