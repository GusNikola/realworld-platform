locals {
  prefix = "${var.project}-bootstrap"

  github_oidc_url = "token.actions.githubusercontent.com"

  # GitHub issues immutable OIDC subjects that carry the owner and repository IDs
  # (repo:<owner>@<owner_id>/<repo>@<repo_id>:...). A deleted and recreated repository
  # with the same name gets a new ID, so it cannot assume these roles.
  github_subject = {
    for repo, id in var.github_repo_ids :
    repo => "repo:${var.github_owner}@${var.github_owner_id}/${repo}@${id}"
  }
}
