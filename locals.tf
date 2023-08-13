locals {
  servers = concat(
    [
      for i in range(var.managers_count) : {
        name        = "manager-${format("%02d", i + 1)}"
        role        = "manager"
        server_type = var.managers_server_type
        ip          = "10.0.0.${i + 2}"
      }
    ],
    flatten([
      for i, s in var.worker_nodepools : [
        for j in range(s.count) : {
          name        = "${s.name}-${format("%02d", j + 1)}"
          role        = s.name
          server_type = s.server_type
          ip          = "10.0.${coalesce(s.private_ip_index, i) + 1}.${j + 1}"
        }
      ]
    ])
  )
  bastion_server_name = "manager-01"
  bastion_server      = one([for s in local.servers : s if s.name == local.bastion_server_name])
  bastion_ip          = hcloud_server.servers[local.bastion_server_name].ipv4_address
}
