locals {
  network_ipv4_subnets = [
    for index in range(256) : cidrsubnet(var.network_ipv4_cidr, 8, index)
  ]
}

resource "hcloud_network" "swarm" {
  name     = var.cluster_name
  ip_range = var.network_ipv4_cidr
}

resource "hcloud_network_subnet" "node" {
  count        = length(var.nodes)
  network_id   = hcloud_network.swarm.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = local.network_ipv4_subnets[count.index]
}

resource "hcloud_firewall" "swarm" {
  for_each = { for f in local.firewalls : f.name => f }
  name     = "${var.cluster_name}-${each.value.name}"

  dynamic "rule" {
    for_each = { for i, p in each.value.ports : i => p }
    content {
      port      = rule.value
      direction = "in"
      protocol  = "tcp"
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

resource "hcloud_firewall" "ssh" {
  name = "${var.cluster_name}-ssh"

  rule {
    port       = var.ssh_port
    direction  = "in"
    protocol   = "tcp"
    source_ips = var.my_ip_addresses
  }
}

resource "hcloud_load_balancer" "swarm" {
  for_each           = { for l in local.load_balancers : l.name => l }
  name               = "${var.cluster_name}-${each.key}"
  load_balancer_type = each.value.type
  location           = each.value.location
}

resource "hcloud_load_balancer_network" "lb_networks" {
  for_each         = { for l in local.load_balancers : l.name => l }
  load_balancer_id = hcloud_load_balancer.swarm[each.key].id
  network_id       = hcloud_network.swarm.id
  ip               = each.value.private_ipv4
}

resource "hcloud_load_balancer_target" "lb_targets" {
  for_each         = { for t in local.servers : t.server_name => t if t.lb_type != null }
  type             = "server"
  load_balancer_id = hcloud_load_balancer.swarm[each.value.name].id
  server_id        = hcloud_server.servers[each.key].id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.lb_networks,
    hcloud_server_network.servers
  ]
}

resource "hcloud_placement_group" "swarm" {
  for_each = { for pg in local.placement_groups : pg.name => pg }
  name     = "${var.cluster_name}-${each.value.name}"
  type = each.value.type
}