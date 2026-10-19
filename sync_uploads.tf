resource "kubernetes_manifest" "sync_uploads" {
  count    = var.initial_setup == true ? 0 : 1
  manifest = yamldecode(local.sync_uploads_manifest)
}

locals {
  sync_uploads_manifest = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sync-uploads
  namespace: "${kubernetes_namespace_v1.this.metadata[0].name}"
  labels:
    app: sync-uploads
    app.kubernetes.io/instance: "${var.release_name}"
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
        app.kubernetes.io/instance: "${var.release_name}"
        app.kubernetes.io/name: sync-uploads
    spec:
      securityContext:
        seLinuxOptions:
          level: "${local.selinux_level}"
      containers:
        - name: mc
          image: pgsty/mc:latest
          command: ["/usr/bin/mc"]
          args:
            - mirror
            - --quiet
            - --overwrite
            - --watch
            - /uploads/
            - "s3/${local.s3_cdn_wordpresss_uploads_path}"
          env:
            - name: MC_HOST_s3
              valueFrom:
                secretKeyRef:
                  name: "${kubernetes_secret_v1.sync_uploads_s3.metadata[0].name}"
                  key: MC_HOST_s3
          volumeMounts:
            - name: uploads
              mountPath: /uploads
      volumes:
        - name: uploads
          persistentVolumeClaim: 
            claimName : "${kubernetes_persistent_volume_claim_v1.wordpress_uploads.metadata[0].name}"
YAML

}