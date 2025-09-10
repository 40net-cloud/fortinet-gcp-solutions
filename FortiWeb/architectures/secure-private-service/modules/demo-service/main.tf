
/*resource "google_cloud_run_v2_service" "itworks" {
    name = "bm-itworks"
    location = "europe-west6"
    ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

    template {
        containers {
            image = "eu.gcr.io/forti-emea-se/itworks:latest"
            ports {
                container_port = 80
            }
            startup_probe {
              tcp_socket {
                port = 80
              }
            }
        }
        vpc_access {
            network_interfaces {
                network    = google_compute_network.itworks.id
                subnetwork = google_compute_subnetwork.run.id
            }
            egress = "ALL_TRAFFIC"
        }
    }
}

resource "google_cloud_run_v2_service" "itworks_info" {
    name = "bm-itworks-info"
    location = "europe-west6"
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
        vpc_access {
      network_interfaces {
        network    = google_compute_network.itworks.id
        subnetwork = google_compute_subnetwork.run.id
      }
      egress = "ALL_TRAFFIC"
    }
    }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.itworks.location
  name     = google_cloud_run_v2_service.itworks.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "noauth-info" {
  location = google_cloud_run_v2_service.itworks_info.location
  name     = google_cloud_run_v2_service.itworks_info.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_network" "itworks" {
    name = "bm-itworks-psc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "run" {
    name = var.prefix
    region = var.region
    ip_cidr_range = "10.0.0.0/24"
    network = google_compute_network.itworks.id
}

resource "google_compute_subnetwork" "psc" {
    name = "${var.prefix}-psc"
    region = var.region
    ip_cidr_range = "10.10.10.0/24"
    network = google_compute_network.itworks.id
    purpose = "PRIVATE_SERVICE_CONNECT"
}

resource "google_compute_subnetwork" "prx" {
    name = "${var.prefix}-psc-prx"
    region = var.region
    ip_cidr_range = "10.10.9.0/24"
    network = google_compute_network.itworks.id
    purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
    role          = "ACTIVE"
}



resource "google_compute_region_network_endpoint_group" "itworks" {
  name                  = "${var.prefix}-psc-neg"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_v2_service.itworks.location
  cloud_run {
    service = google_cloud_run_v2_service.itworks.name
  }
}

resource "google_compute_region_network_endpoint_group" "info" {
  name                  = "${var.prefix}-info-psc-neg"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_v2_service.itworks_info.location
  cloud_run {
    service = google_cloud_run_v2_service.itworks_info.name
  }
}

resource "google_compute_region_backend_service" "itworks" {
  name                  = "${var.prefix}-psc-bes"
  region                = google_cloud_run_v2_service.itworks.location
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTPS"
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_region_network_endpoint_group.itworks.id
  }
}

resource "google_compute_region_backend_service" "info" {
  name                  = "${var.prefix}-info-psc-bes"
  region                = google_cloud_run_v2_service.itworks_info.location
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTPS"
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_region_network_endpoint_group.info.id
  }
}

resource "google_compute_region_url_map" "itworks" {
  name            = "${var.prefix}-psc-urlmap"
  region          = google_cloud_run_v2_service.itworks.location
  default_service = google_compute_region_backend_service.itworks.id

  host_rule {
    hosts = ["*"]
    path_matcher = "just-works"
  }

  path_matcher {
    name = "just-works"
    default_service = google_compute_region_backend_service.itworks.id

    path_rule {
      paths = ["/info"]
      service = google_compute_region_backend_service.info.id
    }
  }
}

resource "google_compute_region_target_http_proxy" "itworks" {
  name    = "${var.prefix}-psc-proxy"
  region  = google_cloud_run_v2_service.itworks.location
  url_map = google_compute_region_url_map.itworks.id
}

resource "google_compute_forwarding_rule" "itworks" {
  name                  = "${var.prefix}-psc"
  region                = google_cloud_run_v2_service.itworks.location
  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.itworks.id
  subnetwork            = google_compute_subnetwork.run.id
  allow_global_access   = true
}

resource "google_compute_service_attachment" "itworks" {
  name   = "${var.prefix}-psc"
  region = var.region

  domain_names          = ["p.gcp.40net.cloud."]
  connection_preference = "ACCEPT_AUTOMATIC"
  enable_proxy_protocol = false
  nat_subnets           = [google_compute_subnetwork.psc.id]
  target_service        = google_compute_forwarding_rule.itworks.id
}

output "psc" {
    value = google_compute_service_attachment.itworks.self_link
}

*/

resource "google_compute_url_map" "demo" {
  name            = "${var.prefix}-urlmap"
  default_service = google_compute_backend_bucket.static.id

  host_rule {
    hosts = ["*"]
    path_matcher = "demoapp"
  }

  path_matcher {
    name = "demoapp"
    default_service = google_compute_backend_bucket.static.id

    path_rule {
      paths = ["/info"]
      service = google_compute_backend_service.infoapp.id
    }
  }
}

resource "google_compute_target_http_proxy" "demo" {
  name    = var.prefix
  url_map = google_compute_url_map.demo.id
}

resource "google_compute_global_forwarding_rule" "demo" {
  name                  = var.prefix
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.demo.id
}

resource "random_string" "suffix" {
    length = 5
    special = false
    upper = false
}