data "google_client_config" "default" {}

locals {
  project_id = data.google_client_config.default.project
}