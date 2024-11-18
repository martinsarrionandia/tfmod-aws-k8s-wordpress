
resource "kubernetes_manifest" "this_dns_endpoint" {
  manifest = yamldecode(local.dns-endpoint-manifest)
}

locals {

  dns-endpoint-manifest = <<EOF
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: ${var.release-name}-record
  namespace: ${kubernetes_namespace.this.metadata.0.name}
spec:
  endpoints:
  - dnsName: ${local.fqdn}
    recordTTL: 300
    recordType: A
    targets:
    - ${var.public-ip}

  EOF
}