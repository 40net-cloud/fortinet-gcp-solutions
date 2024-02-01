resource "google_network_connectivity_policy_based_route" "via_fgt" {
    name = "${var.prefix}-pbr-via-fgt"
    network = module.networks["hub"].network_id
    priority = 200

    filter {
        protocol_version = "IPV4"
        src_range = "10.10.0.0/16"
    }

    next_hop_ilb_ip = module.fgt_ha.ilb_address
}

resource "google_network_connectivity_policy_based_route" "skip_fgt" {
    name = "${var.prefix}-pbr-skip-fgt"
    network = module.networks["hub"].network_id
    priority = 10

    filter {
        protocol_version = "IPV4"
    }

    virtual_machine {
        tags = ["fgt"]
    }
    next_hop_other_routes = "DEFAULT_ROUTING"
}