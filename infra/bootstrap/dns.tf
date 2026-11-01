# Public hosted zone for the delegated subdomain. The parent domain stays on Cloudflare;
# delegation is a one-time manual step (NS records in Cloudflare)

resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Delegated from Cloudflare (${var.parent_domain}); managed by Terraform"

  lifecycle {
    prevent_destroy = true
  }
}
