data "aws_ebs_volume" "wordpress_root" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ebs-volname-wordpress-root]
  }
}

data "aws_ebs_volume" "wordpress_maria" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ebs-volname-wordpress-mariadb]
  }
}

data "aws_ebs_volume" "wordpress_uploads" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ebs-volname-wordpress-uploads]
  }
}

resource "kubernetes_persistent_volume" "wordpress_root" {
  metadata {
    name = "${var.release-name}-wordpress-root"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = data.aws_ebs_volume.wordpress_root.id
        fs_type   = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_root" {
  metadata {
    name      = "${var.release-name}-wordpress-root-claim"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress_root.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "wordpress_maria" {
  metadata {
    name = "${var.release-name}-wordpress-maria"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = data.aws_ebs_volume.wordpress_maria.id
        fs_type   = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_maria" {
  metadata {
    name      = "${var.release-name}-wordpress-maria-claim"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress_maria.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "wordpress_uploads" {
  metadata {
    name = "${var.release-name}-wordpress-uploads"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    capacity = {
      storage = "24Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = data.aws_ebs_volume.wordpress_uploads.id
        fs_type   = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_uploads" {
  metadata {
    name      = "${var.release-name}-wordpress-uploads-claim"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon-ebs-class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "24Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress_uploads.metadata[0].name
  }
}