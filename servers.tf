resource "hcloud_server" "servers" {
  for_each    = { for s in local.servers : s.server_name => s }
  name        = "${var.cluster_name}-${each.value.server_name}"
  image       = var.server_image
  server_type = each.value.server_type
  location    = each.value.location
  firewall_ids = local.bastion_name == each.value.server_name ? [
    hcloud_firewall.ssh.id,
    hcloud_firewall.swarm[each.value.name].id
    ] : [
    hcloud_firewall.swarm[each.value.name].id
  ]
  ssh_keys = var.hcloud_ssh_keys
  depends_on = [
    hcloud_network_subnet.node,
    hcloud_placement_group.swarm
  ]
  user_data = <<-EOT
#cloud-config
${yamlencode(local.cloud_init)}
EOT

  placement_group_id = contains(keys(hcloud_placement_group.swarm), each.value.name) ? hcloud_placement_group.swarm[each.value.name].id : null

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys,
    ]
  }
}

resource "hcloud_server_network" "servers" {
  for_each   = { for s in local.servers : s.server_name => s }
  server_id  = hcloud_server.servers[each.value.server_name].id
  network_id = hcloud_network.swarm.id
  ip         = each.value.private_ipv4
}