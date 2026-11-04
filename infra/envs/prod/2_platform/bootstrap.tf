# GitOps Bridge: AWS values produced by Terraform are handed to ArgoCD as annotations
# on the cluster secret. ApplicationSets read them through the cluster generator, so
# no ARNs or account specific names are committed to gitops/.
resource "kubernetes_secret_v1" "in_cluster" {
  metadata {
    name      = "in-cluster"
    namespace = helm_release.argocd.namespace

    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      environment                      = local.env
    }

    annotations = {
      aws_region     = "us-east-1"
      aws_account_id = data.aws_caller_identity.current.account_id
      cluster_name   = local.infra.cluster_name
      vpc_id         = local.infra.vpc_id

      domain         = local.domain
      app_host       = local.app_host
      argocd_host    = local.argocd_host
      grafana_host   = local.grafana_host
      hosted_zone_id = local.bootstrap.hosted_zone_id

      acm_certificate_arn = local.bootstrap.wildcard_certificate_arn
      waf_web_acl_arn     = local.infra.waf_web_acl_arn
      waf_web_acl_name    = local.infra.waf_web_acl_name

      karpenter_role_arn       = local.infra.karpenter_controller_role_arn
      karpenter_node_role_name = local.infra.karpenter_node_role_name
      karpenter_queue_name     = local.infra.karpenter_interruption_queue_name

      lbc_role_arn              = local.infra.irsa_role_arns.aws_load_balancer_controller
      external_dns_role_arn     = local.infra.irsa_role_arns.external_dns
      external_secrets_role_arn = local.infra.irsa_role_arns.external_secrets
      loki_role_arn             = local.infra.irsa_role_arns.loki
      loki_bucket               = local.infra.loki_bucket

      rds_address               = local.infra.rds_address
      rds_port                  = tostring(local.infra.rds_port)
      rds_db_name               = local.infra.rds_db_name
      rds_secret_arn            = local.infra.rds_master_user_secret_arn
      backend_secret_name       = local.infra.backend_secret_name
      grafana_admin_secret_name = local.infra.grafana_admin_secret_name

      ecr_registry    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com"
      gitops_repo_url = local.gitops_repo_url
      gitops_revision = var.gitops_revision
    }
  }

  data = {
    name   = "in-cluster"
    server = "https://kubernetes.default.svc"
    config = jsonencode({ tlsClientConfig = { insecure = false } })
  }
}

# Root of the app-of-apps. Installed through the argocd-apps chart because the
# Application CRD does not exist yet when Terraform plans the first apply.
resource "helm_release" "root_apps" {
  name       = "root-argo-apps"
  namespace  = helm_release.argocd.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.7"

  values = [yamlencode({
    applications = {
      root-argo-apps = {
        namespace  = helm_release.argocd.namespace
        finalizers = ["resources-finalizer.argocd.argoproj.io"]
        project    = "default"
        source = {
          repoURL        = local.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = "gitops/root-argo-apps"
          helm = {
            valuesObject = {
              repoURL        = local.gitops_repo_url
              targetRevision = var.gitops_revision
            }
          }
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = helm_release.argocd.namespace
        }
        syncPolicy = {
          automated = { prune = true, selfHeal = true }
        }
      }
    }
  })]

  depends_on = [kubernetes_secret_v1.in_cluster]
}
