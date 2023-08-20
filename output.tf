output "network" {
  value       = hcloud_network.network
  description = "Private network"
}


output "firewall_workers" {
  value       = hcloud_firewall.firewall_workers
  description = "Private firewall, allowing attaching to any custom servers"
}

output "lbs" {
  value       = hcloud_load_balancer.lbs
  description = "Hetzner load balancers, use them to configure services"
}


output "managers" {
  value       = [for s in local.servers : hcloud_server.servers[s.name] if s.role == "manager"]
  description = "Managers"
}

output "workers" {
  value       = [for s in local.servers : hcloud_server.servers[s.name] if s.role == "worker"]
  description = "Workers"
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
