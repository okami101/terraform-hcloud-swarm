resource "hcloud_server" "servers" {
  for_each    = { for i, s in local.servers : s.name => s }
  name        = "${var.cluster_name}-${each.value.name}"
  image       = var.server_image
  location    = var.server_location
  server_type = each.value.server_type
  firewall_ids = concat(
    [hcloud_firewall.firewall_private.id],
    each.value.role == "manager" ? [hcloud_firewall.firewall_managers.id] : []
  )
  ssh_keys = var.my_ssh_key_names
  depends_on = [
    hcloud_network_subnet.network_subnet
  ]
  user_data = templatefile("${path.module}/cloud-init.tftpl", {
    server_timezone = var.server_timezone
    server_locale   = var.server_locale
    server_packages = var.server_packages
    ssh_port        = var.ssh_port
    minion_id       = each.value.name
    bastion_ip      = local.bastion_server.ip
    is_bastion      = each.value.name == local.bastion_server_name
    cluster_name    = var.cluster_name
    cluster_user    = var.cluster_user
    public_ssh_keys = var.my_public_ssh_keys
  })

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys
    ]
  }
}

resource "hcloud_server_network" "servers" {
  for_each   = { for i, s in local.servers : s.name => s }
  server_id  = hcloud_server.servers[each.value.name].id
  network_id = hcloud_network.network.id
  ip         = each.value.ip
}

resource "hcloud_volume" "volumes" {
  for_each  = { for i, s in local.servers : s.name => s if s.volume_size >= 10 }
  name      = "${var.cluster_name}-${each.value.name}"
  size      = each.value.volume_size
  server_id = hcloud_server.servers[each.key].id
  automount = true
  format    = each.value.volume_format != null ? each.value.volume_format : "ext4"
}
