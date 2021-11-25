# Configuration for Active Instance using user-data
data "template_file" "setup-active-instance" {
  template = "${file("${path.module}/active")}"
  vars = {
    fgt_password      = var.password
    active_port1_ip   = var.active_port1_ip
    active_port1_mask = var.active_port1_mask
    active_port2_ip   = var.active_port2_ip
    active_port2_mask = var.active_port2_mask
    active_port3_ip   = var.active_port3_ip
    active_port3_mask = var.active_port3_mask
    active_port4_ip   = var.active_port4_ip
    active_port4_mask = var.active_port4_mask
    hamgmt_gateway_ip = var.mgmt_gateway     //  HA Management Gateway IP
    passive_hb_ip     = var.passive_port3_ip // Passive Sync (HeartBeat) IP
    hb_netmask        = var.mgmt_mask        // Management netmask
    public_gateway    = var.public_subnet_gateway
    clusterip         = "${var.name}-cluster-ip-${var.random_string}"
    internalroute     = "${var.name}-internal-route-${var.random_string}"
  }
}

# Configuration for Passive Instance using user-data
data "template_file" "setup-passive-instance" {
  template = "${file("${path.module}/passive")}"
  vars = {
    fgt_password       = var.password
    passive_port1_ip   = var.passive_port1_ip
    passive_port1_mask = var.passive_port1_mask
    passive_port2_ip   = var.passive_port2_ip
    passive_port2_mask = var.passive_port2_mask
    passive_port3_ip   = var.passive_port3_ip
    passive_port3_mask = var.passive_port3_mask
    passive_port4_ip   = var.passive_port4_ip
    passive_port4_mask = var.passive_port4_mask
    hamgmt_gateway_ip  = var.mgmt_gateway    //  HA Management Gateway IP
    active_hb_ip       = var.active_port3_ip // Active Sync (HeartBeat) IP
    hb_netmask         = var.mgmt_mask       // Management netmask
    public_gateway     = var.public_subnet_gateway
    clusterip         = "${var.name}-cluster-ip-${var.random_string}"
    internalroute     = "${var.name}-internal-route-${var.random_string}"
  }
}
