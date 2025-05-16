# locals.tf
locals {
  common_tags = {
    environment = var.environment
    project     = var.project
  }
}