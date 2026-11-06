#!/usr/bin/env bash
# Renders every local Helm chart under gitops/ for each environment, the way the
# ApplicationSets do, with placeholder values in place of the cluster secret
# annotations. Fails on template errors, missing required values or invalid YAML.
set -euo pipefail

cd "$(dirname "$0")/../.."

# Superset of the values the ApplicationSets pass in; each chart ignores the rest.
placeholders=(
  host=app.example.com
  webhookSecretName=env/argocd-webhook
  grafanaHost=grafana.example.com
  grafanaAdminSecretName=env/grafana-admin
  region=us-east-1
  certificateArn=arn:aws:acm:us-east-1:000000000000:certificate/placeholder
  webAclArn=arn:aws:wafv2:us-east-1:000000000000:regional/webacl/placeholder/0
  clusterName=placeholder
  nodeRoleName=placeholder-node
  repoURL=https://github.com/example/realworld-platform.git
  targetRevision=main
  registry=000000000000.dkr.ecr.us-east-1.amazonaws.com
  trustedProxyCidr=10.0.0.0/16
  postgres.host=db.example.com
  postgres.port=5432
  postgres.db=realworld
  secrets.backend=env/backend
  secrets.rds=arn:aws:secretsmanager:us-east-1:000000000000:secret:placeholder
)

status=0
for chart in $(find gitops -name Chart.yaml -exec dirname {} \; | sort); do
  for env in dev prod; do
    args=()
    [ -f "$chart/values.yaml" ] && args+=(-f "$chart/values.yaml")
    [ -f "$chart/values-$env.yaml" ] && args+=(-f "$chart/values-$env.yaml")
    sets=("${placeholders[@]}" "environment=$env")
    if [ "$chart" = gitops/realworld/chart ]; then
      args+=(-f "gitops/realworld/values-$env.yaml")
      # Image tags are empty until CI deploys to the environment.
      sets+=(backend.image.tag=placeholder frontend.image.tag=placeholder)
    fi
    if out=$(helm template ci "$chart" "${args[@]}" --set "$(IFS=,; echo "${sets[*]}")" 2>&1); then
      echo "ok    $chart [$env] ($(grep -c '^kind:' <<<"$out") resources)"
    else
      echo "FAIL  $chart [$env]"
      echo "$out" | tail -5
      status=1
    fi
  done
done
exit $status
