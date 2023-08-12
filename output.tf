output "network_id" {
  value       = hcloud_network.network.id
  description = "ID of the private firewall"
}


output "firewall_private_id" {
  value       = hcloud_firewall.firewall_private.id
  description = "ID of the private firewall, allowing attaching to any custom servers"
}

output "manager_ids" {
  value       = [for s in local.servers : hcloud_server.servers[s.name].id if s.role == "manager"]
  description = "Hetzner Identifier of controllers"
}

output "worker_ids" {
  value       = [for s in local.servers : hcloud_server.servers[s.name].id if s.role == "worker"]
  description = "Hetzner Identifier of workers"
}

output "ssh_config" {
  description = "SSH config to access to the server"
  value = templatefile("${path.module}/ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    ssh_port     = var.ssh_port
    bastion_ip   = local.bastion_ip
    servers      = local.servers
  })
}
