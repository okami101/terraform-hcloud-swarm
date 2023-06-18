resource "hcloud_server" "servers" {
  for_each    = { for i, s in local.servers : s.name => s }
  name        = "${var.cluster_name}-${each.value.name}"
  image       = var.server_image
  location    = var.server_location
  server_type = each.value.server_type
  firewall_ids = [
    hcloud_firewall.firewall_ssh.id
  ]
  ssh_keys = [
    var.my_public_ssh_name
  ]
  depends_on = [
    hcloud_network_subnet.network_subnet
  ]
  user_data = templatefile("init_server.tftpl", {
    server_timezone = var.server_timezone
    server_locale   = var.server_locale
    minion_id       = each.value.name
    is_bastion      = each.value.ip == "10.0.0.2"
    cluster_name    = var.cluster_name
    cluster_user    = var.cluster_user
    public_ssh_key  = var.my_public_ssh_key
  })

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys
    ]
  }

  network {
    network_id = hcloud_network.network.id
    ip         = each.value.ip
  }
}
