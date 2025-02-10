locals {
  bastion_name = local.servers[0].server_name
  servers = flatten([
    for s in var.nodes : [
      for j in range(s.count) : {
        name        = s.name
        server_name = "${s.name}-${format("%02d", j + 1)}"
        server_type = s.server_type
        location    = s.location
        private_ipv4 = cidrhost(
          hcloud_network_subnet.node[[
            for i, v in var.nodes : i if v.name == s.name][0]
        ].ip_range, j + 101)
        lb_type = s.lb_type
      }
    ]
  ])
  load_balancers = [
    for s in var.nodes : {
      name     = s.name
      type     = s.lb_type
      location = s.location
      private_ipv4 = cidrhost(
        hcloud_network_subnet.node[[
          for i, v in var.nodes : i if v.name == s.name][0]
      ].ip_range, 200)
    } if s.lb_type != null
  ]
  firewalls = [
    for s in var.nodes : {
      name  = s.name
      ports = s.ports != null ? s.ports : []
    }
  ]
  cloud_init = {
    users = [
      {
        name                = var.cluster_user
        uid                 = 1000
        shell               = "/bin/bash"
        sudo                = "ALL=(ALL) NOPASSWD:ALL"
        groups              = ["adm", "sudo", "docker"]
        ssh_authorized_keys = var.cluster_user_public_ssh_keys
      }
    ],
    package_update             = true
    package_upgrade            = true
    package_reboot_if_required = true
    locale                     = var.server_locale
    timezone                   = var.server_timezone
    packages                   = var.server_packages
    write_files = [
      {
        path        = "/etc/ssh/sshd_config.d/99-custom.conf"
        permissions = "0644"
        content     = <<-EOT
Port ${var.ssh_port}
PasswordAuthentication no
EOT
      },
      {
        path        = "/etc/docker/daemon.json"
        permissions = "0644"
        content     = jsonencode(var.docker_config)
      },
    ]
    runcmd = [
      "systemctl restart sshd",
      "curl -fsSL https://get.docker.com | sh",
    ]
  }
}