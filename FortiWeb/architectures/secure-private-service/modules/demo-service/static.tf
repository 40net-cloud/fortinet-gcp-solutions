

resource "google_storage_bucket" "static" {
    name = "${var.prefix}-static-${random_string.suffix.result}"
    location = var.region
    force_destroy = true
    uniform_bucket_level_access = true
    storage_class = "REGIONAL"

    website {
        main_page_suffix = "index.html"
    }
}

locals {
    static_files = ["index.html", "blue.png", "dots.png", "logo.png", "white.png"]
}

resource "google_storage_bucket_object" "files" {
    for_each = toset(local.static_files)

    name = each.value
    source = "${path.module}/static/${each.value}"
    bucket = google_storage_bucket.static.name
}

resource "google_storage_bucket_iam_member" "static_public" {
    bucket = google_storage_bucket.static.name
    role = "roles/storage.objectViewer"
    member = "allUsers"
}

resource "google_compute_backend_bucket" "static" {
    name = "${var.prefix}-static"
    bucket_name = google_storage_bucket.static.name
}