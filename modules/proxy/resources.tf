resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-${var.user_component}"
    labels = {
      app            = "nginx"
      user_component = var.user_component
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app            = "nginx"
        user_component = var.user_component
      }
    }

    template {
      metadata {
        labels = {
          app            = "nginx"
          user_component = var.user_component
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.image

          env {
            name = "CONFIGMAP_RESOURCEVERSION"
            value = kubernetes_config_map.nginx.metadata.0.resource_version
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/nginx/conf.d/custom.conf"
            sub_path    = "custom.conf"
          }

          volume_mount {
            name       = "certificate"
            mount_path = "/etc/nginx/ssl"
            read_only  = true
          }

          resources {
            limits {
              cpu    = var.cpu_limit
              memory = var.ram_limit
            }
            requests {
              cpu    = var.cpu_request
              memory = var.ram_request
            }
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.nginx.metadata.0.name
          }
        }

        volume {
          name = "certificate"

          secret {
            secret_name = "ssl-certificate"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "nginx" {
  metadata {
    name = "nginx-${var.user_component}"
  }

  data = {
    "custom.conf" = templatefile("${path.module}/templates/default.conf",
    { service = var.backend_service })
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-${var.user_component}"
  }

  spec {
    selector = kubernetes_deployment.nginx.metadata.0.labels

    port {
      port        = 443
      target_port = 443
    }

    type = "ClusterIP"
  }
}
