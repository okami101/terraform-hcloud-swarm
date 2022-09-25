resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  network_id   = hcloud_network.network.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
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
