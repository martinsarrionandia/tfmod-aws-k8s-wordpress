resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "${var.release-name}-${var.release-chart}"
    labels = {
      "pod-security.kubernetes.io/enforce" = var.initial-setup ? "privileged" : "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}