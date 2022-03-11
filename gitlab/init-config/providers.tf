terraform {
  required_version = ">= 1.0"
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 3.12"
    }
  }
}

provider "gitlab" {
  token = var.root_token
  base_url = var.gitlab_url
}
