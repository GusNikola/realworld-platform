locals {
  cluster_host = trimprefix(local.infra.cluster_endpoint, "https://")

  # Through a port-forward the API server is reached on localhost, so the TLS server
  # name must still be the real endpoint host for certificate validation.
  kubernetes = {
    host                   = coalesce(var.cluster_endpoint_override, local.infra.cluster_endpoint)
    tls_server_name        = var.cluster_endpoint_override == null ? null : local.cluster_host
    cluster_ca_certificate = base64decode(local.infra.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.infra.cluster_name, "--region", "us-east-1"]
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "realworld"
      Layer       = "platform"
      Environment = "dev"
      ManagedBy   = "terraform"
      Repository  = "GusNikola/realworld-platform"
    }
  }
}

provider "kubernetes" {
  host                   = local.kubernetes.host
  tls_server_name        = local.kubernetes.tls_server_name
  cluster_ca_certificate = local.kubernetes.cluster_ca_certificate

  exec {
    api_version = local.kubernetes.exec.api_version
    command     = local.kubernetes.exec.command
    args        = local.kubernetes.exec.args
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.kubernetes.host
    tls_server_name        = local.kubernetes.tls_server_name
    cluster_ca_certificate = local.kubernetes.cluster_ca_certificate
    exec                   = local.kubernetes.exec
  }
}
