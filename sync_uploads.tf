resource "kubernetes_manifest" "sync_uploads" {
  count    = var.initial-setup == true ? 0 : 1
  manifest = yamldecode(local.sync-uploads-manifest)
}

locals {
  sync-uploads-manifest = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sync-uploads
  namespace: "${kubernetes_namespace_v1.this.metadata[0].name}"
  labels:
    app: sync-uploads
    app.kubernetes.io/instance: "${var.release-name}"
    app.kubernetes.io/name: sync-uploads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sync-uploads
  template:
    metadata:
      labels:
        app: sync-uploads
        app.kubernetes.io/instance: "${var.release-name}"
        app.kubernetes.io/name: sync-uploads
    spec:
      securityContext:
        seLinuxOptions:
          level: "${local.selinux-level}"
      containers:
        - name: mc
          image: minio/mc:latest
          command: ["sh", "-c"]
          args:
          - |
            mc alias set s3 https://s3.${local.s3-region}.amazonaws.com:443 "${local.aws_access_key_id}" "${local.aws_secret_access_key}"
            mc mirror --quiet --overwrite --watch /uploads/ s3/"${local.s3-cdn-wordpresss-uploads-path}"
          env:
          - name: AWS_ACCESS_KEY_ID
            value: "${local.aws_access_key_id}"
          - name: AWS_SECRET_ACCESS_KEY
            value: "${local.aws_secret_access_key}"
          volumeMounts:
            - name: uploads
              mountPath: /uploads
      volumes:
        - name: uploads
          persistentVolumeClaim: 
            claimName : "${kubernetes_persistent_volume_claim_v1.wordpress_uploads.metadata[0].name}"
YAML

}