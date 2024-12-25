output "lbs" {
  value       = hcloud_load_balancer.swarm
  description = "Hetzner load balancers, use them to configure services"
}

output "ssh_config" {
  description = "SSH config to access to the server"
  value = templatefile("${path.module}/ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    ssh_port     = var.ssh_port
    servers      = local.servers
    bastion_ip = hcloud_server.servers[
      local.servers[0].server_name
    ].ipv4_address
  })
}
