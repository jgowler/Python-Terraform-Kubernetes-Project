terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "kubernetes" {
  host                   = var.k8s_server
  cluster_ca_certificate = base64decode(var.k8s_ca)
  client_certificate     = base64decode(var.k8s_client_cert)
  client_key             = base64decode(var.k8s_client_key)
}


resource "kubernetes_deployment" "flask_app" {
  metadata {
    name      = "flask-users-app"
    namespace = "default"
    labels = {
      app = "flask-users-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "flask-users-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-users-app"
        }
      }

      spec {
        container {
          name  = "flask-users-app"
          image = "jgowler/flask-users-app:latest"

          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_app_nodeport" {
  metadata {
    name      = "flask-users-app"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.flask_app.metadata[0].labels.app
    }

    type = "NodePort"

    port {
      port        = 5000
      target_port = 5000
      node_port   = 30080
      protocol    = "TCP"
    }
  }
}
