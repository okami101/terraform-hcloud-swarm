resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  network_id   = hcloud_network.network.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/16"
}

resource "hcloud_firewall" "firewall_ssh" {
  name = "firewall-ssh"
  rule {
    direction  = "in"
    port       = "2222"
    protocol   = "tcp"
    source_ips = var.my_ip_addresses
  }
}

resource "hcloud_load_balancer" "lb" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = var.lb_type
  location           = var.server_location
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.0.100"
}

resource "hcloud_load_balancer_target" "lb_targets" {
  for_each         = { for i, t in local.servers : t.name => t if t.name != "manager" }
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.servers[each.key].id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.lb_network,
    hcloud_server_network.servers
  ]
}
