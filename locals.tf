locals {
  servers = flatten([
    [
      for i in range(var.managers_count) : {
        name        = "manager-${format("%02d", i + 1)}"
        role        = "manager"
        server_type = var.managers_server_type
        ip          = "10.0.0.${i + 2}"
      }
    ],
    [
      for i in range(var.workers_count) : {
        name        = "worker-${format("%02d", i + 1)}"
        role        = "worker"
        server_type = var.workers_server_type
        ip          = "10.0.1.${i + 1}"
      }
    ]
  ])
  bastion_server_name = "manager-01"
  bastion_server      = one([for s in local.servers : s if s.name == local.bastion_server_name])
  bastion_ip          = hcloud_server.servers[local.bastion_server_name].ipv4_address
}
