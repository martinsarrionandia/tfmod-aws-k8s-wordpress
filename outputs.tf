output "helm-render" {
    value = yamlencode(data.helm_template.wordpress.manifest)
}