output "argocd_url" {
  value = "https://${local.argocd_host}"
}

output "grafana_url" {
  value = "https://${local.grafana_host}"
}

output "app_url" {
  value = "https://${local.app_host}"
}
