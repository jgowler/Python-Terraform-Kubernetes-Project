variable "k8s_server" {
  description = "URL of the Kubernetes API server"
  type        = string
}

variable "k8s_ca" {
  description = "Base64 encoded Kubernetes cluster CA certificate"
  type        = string
}

variable "k8s_client_cert" {
  description = "Base64 encoded client certificate"
  type        = string
}

variable "k8s_client_key" {
  description = "Base64 encoded client key"
  type        = string
}
