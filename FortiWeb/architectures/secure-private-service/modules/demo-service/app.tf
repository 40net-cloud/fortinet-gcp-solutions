resource "google_cloud_run_v2_service" "infoapp" {
    name = "${var.prefix}-infoapp"
    location = var.region
    ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

    template {
        containers {
            image = "eu.gcr.io/forti-emea-se/itworks-info:latest"
            ports {
                container_port = 80
            }
            startup_probe {
              tcp_socket {
                port = 80
              }
            }
        }
        /* vpc_access {
            network_interfaces {
                network    = google_compute_network.itworks.id
                subnetwork = google_compute_subnetwork.run.id
            }
            egress = "ALL_TRAFFIC"
        } */
    }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.infoapp.location
  name     = google_cloud_run_v2_service.infoapp.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "infoapp" {
  name                  = "${var.prefix}-infoapp-neg"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_v2_service.infoapp.location
  cloud_run {
    service = google_cloud_run_v2_service.infoapp.name
  }
}

resource "google_compute_backend_service" "infoapp" {
  name                  = "${var.prefix}-infoapp-bes"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_region_network_endpoint_group.infoapp.id
    capacity_scaler = 1.0
  }
}