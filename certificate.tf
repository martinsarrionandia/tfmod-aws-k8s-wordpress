resource "kubernetes_manifest" "this_certificate" {
  manifest = yamldecode(local.certificate_manifest)
  count    = 0
}

locals {

  certificate_manifest = <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${local.fqdn}-cert
  namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
spec:
  secretName: "${local.fqdn}-secret"
  commonName: ${local.fqdn}
  issuerRef:
    name: ${var.cluster_issuer}
    kind: ClusterIssuer
  dnsNames:
    - ${local.fqdn}

EOF
}