output "servers" {
  value       = local.servers
  description = "List of servers"
}

output "manager_ip" {
  value       = hcloud_server.servers["manager"].ipv4_address
  description = "Public ip address of the swarm manager"
}

output "lb_id" {
  value       = hcloud_load_balancer.lb.id
  description = "ID of this load balancer, use for define services into it"
}

output "lb_ip" {
  value       = hcloud_load_balancer.lb.ipv4
  description = "Public ip address of the load balancer, use this IP as main HTTPS entrypoint through your worker nodes"
}

output "ssh_config" {
  description = "SSH config to access to the server"
  value = templatefile("${path.module}/ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    ssh_port     = var.ssh_port
    manager_ip   = hcloud_server.servers["manager"].ipv4_address
    workers      = [for s in local.servers : s if s.name != "manager"]
  })
}
