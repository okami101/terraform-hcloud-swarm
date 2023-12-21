locals {
  servers = concat(
    [
      for i in range(var.managers.count) : {
        name        = "manager-${format("%02d", i + 1)}"
        role        = "manager"
        server_type = var.managers.server_type
        location    = var.managers.location
        ip          = "10.0.0.${i + 2}"
        lb_type     = var.managers.lb_type
        volume_size = 0
      }
    ],
    flatten([
      for i, s in var.worker_nodepools : [
        for j in range(s.count) : {
          name          = "${s.name}-${format("%02d", j + 1)}"
          role          = s.name
          server_type   = s.server_type
          location      = s.location
          ip            = "10.0.${coalesce(s.private_ip_index, i) + 1}.${j + 1}"
          lb_type       = s.lb_type
          volume_size   = s.volume_size != null ? s.volume_size : 0
          volume_format = s.volume_format != null ? s.volume_format : "ext4"
        }
      ]
    ])
  )
  subnets = concat(
    [
      {
        name = "manager"
        ip   = "10.0.0.0/24"
      }
    ],
    [
      for i, s in var.worker_nodepools : {
        name = s.name
        ip   = "10.0.${coalesce(s.private_ip_index, i) + 1}.0/24"
      }
    ]
  )
  load_balancers = concat(
    var.managers.lb_type != null ? [{
      name     = "manager"
      type     = var.managers.lb_type
      location = var.managers.location
      ip       = "10.0.0.100"
    }] : [],
    [
      for i, s in var.worker_nodepools : {
        name     = s.name
        type     = s.lb_type
        location = s.location
        ip       = "10.0.${coalesce(s.private_ip_index, i) + 1}.100"
      } if s.lb_type != null
    ]
  )
  bastion_server_name = "manager-01"
  bastion_server      = one([for s in local.servers : s if s.name == local.bastion_server_name])
  bastion_ip          = hcloud_server.servers[local.bastion_server_name].ipv4_address
}
