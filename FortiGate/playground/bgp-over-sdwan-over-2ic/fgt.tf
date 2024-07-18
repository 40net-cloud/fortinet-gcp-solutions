resource "random_string" "fgtvpnpass" {
    length = 20
    special = true
}

module "fgtgcp" {
    source = "/Users/bam/GitHub/fortinet/terraform-google-fgt-ha-ap-lb/"

    region = var.region
    prefix = var.prefix
    subnets = [
        google_compute_subnetwork.extfw.name,
        google_compute_subnetwork.intfw.name,
        google_compute_subnetwork.hamgmt.name
    ]
    image = {
        version = "7.4"
    }
    flex_tokens = [
      var.flex_tokens[0],
      var.flex_tokens[1]
    ]
    ports_external = []
    routes = {
        "vpn": "172.18.100.0/24"
    }
    service_account = local.fgt_sa
    fgt_config = templatefile( "./fgt_config_gcp.tftpl", {
      overlay_local = local.overlay_gcp
      overlay_remote = local.overlay_remote
      underlay_local1 = local.fwcloud[0]
      underlay_local2 = local.fwcloud[1]
      underlay_remote1 = local.fwremote[0]
      underlay_remote2 = local.fwremote[1]
      port2_gw = cidrhost(var.cidrs.intfw, 1)
      local_subnet = var.cidrs.intsrv
      vpn_secret = random_string.fgtvpnpass.result
    })
    depends_on = [
        google_compute_subnetwork.extfw,
        google_compute_subnetwork.intfw,
        google_compute_subnetwork.hamgmt
    ]
}


data "cloudinit_config" "remote" {
  gzip = false
  base64_encode = false

  part {
    filename = "license"
    content_type = "text/plain; charset=\"us-ascii\""
    content = <<EOF
      LICENSE-TOKEN: ${var.flex_tokens[2]}
      EOF
  }

  part {
    filename = "config"
    content_type = "text/plain; charset=\"us-ascii\""
    content = templatefile( "./fgt_config_remote.tftpl", {
        underlay_me1 = local.fwremote[0],
        underlay_me2 = local.fwremote[1],
        underlay_peer1 = local.fwcloud[0],
        underlay_peer2 = local.fwcloud[1],
        overlay_me = local.overlay_remote,
        overlay_peer = local.overlay_gcp,
        local_subnet = var.cidrs.remote,
        vpn_secret = random_string.fgtvpnpass.result
      })
  }
}

resource "google_compute_instance" "fgtremote" {
    name = "${var.prefix}-fgt-remote"
    machine_type = "e2-standard-2"
    zone = "${var.region}-b"
    boot_disk {
      initialize_params {
        image = "https://www.googleapis.com/compute/v1/projects/fortigcp-project-001/global/images/fortinet-fgt-744-20240516-001-w-license"
      }
    }
    can_ip_forward = true
    network_interface {
      network = google_compute_network.remote.id
      subnetwork = google_compute_subnetwork.remote.id
      alias_ip_range {
        ip_cidr_range = cidrsubnet( google_compute_subnetwork.remote.secondary_ip_range[0].ip_cidr_range, 1, 0 )
        subnetwork_range_name = "vpn"
      }
      access_config {}
    }

    service_account {
      email = local.fgt_sa
      scopes = [
        "cloud-platform"
      ]
    }
    metadata = {
      user-data = data.cloudinit_config.remote.rendered
    }
}