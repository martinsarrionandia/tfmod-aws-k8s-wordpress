data "aws_ebs_volume" "wordpress_root" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ebs_volname_wordpress_root]
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
    values = [var.ebs_volname_wordpress_mariadb]
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
    values = [var.ebs_volname_wordpress_uploads]
  }
}

resource "kubernetes_persistent_volume_v1" "wordpress_root" {
  metadata {
    name = "${var.release_name}-wordpress-root"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon_ebs_class
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

resource "kubernetes_persistent_volume_claim_v1" "wordpress_root" {
  metadata {
    name      = "${var.release_name}-wordpress-root-claim"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon_ebs_class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.wordpress_root.metadata[0].name
  }
}

resource "kubernetes_persistent_volume_v1" "wordpress_maria" {
  metadata {
    name = "${var.release_name}-wordpress-maria"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon_ebs_class
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

resource "kubernetes_persistent_volume_claim_v1" "wordpress_maria" {
  metadata {
    name      = "${var.release_name}-wordpress-maria-claim"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon_ebs_class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.wordpress_maria.metadata[0].name
  }
}

resource "kubernetes_persistent_volume_v1" "wordpress_uploads" {
  metadata {
    name = "${var.release_name}-wordpress-uploads"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    storage_class_name = var.amazon_ebs_class
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

resource "kubernetes_persistent_volume_claim_v1" "wordpress_uploads" {
  metadata {
    name      = "${var.release_name}-wordpress-uploads-claim"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    storage_class_name = var.amazon_ebs_class
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "24Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.wordpress_uploads.metadata[0].name
  }
}