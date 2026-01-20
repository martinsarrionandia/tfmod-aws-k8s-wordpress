resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "${var.release_name}-${var.release_chart}"
    labels = {
      "pod-security.kubernetes.io/enforce" = var.initial_setup ? "privileged" : "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}