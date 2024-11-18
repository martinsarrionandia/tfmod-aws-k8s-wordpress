resource "kubernetes_manifest" "this_certificate" {
  manifest = yamldecode(local.certificate-manifest)
}

locals {

  certificate-manifest = <<EOF

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${local.fqdn}-cert
  namespace: ${kubernetes_namespace.this.metadata.0.name}
spec:
  secretName: "${local.fqdn}-secret"
  issuerRef:
    name: ${var.cluster-issuer}
    kind: ClusterIssuer
  dnsNames:
    - ${local.fqdn}

EOF
}