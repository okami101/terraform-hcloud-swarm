locals {
  servers = flatten([
    [
      for i in range(var.managers.server_count) : {
        name        = "manager-${format("%02d", i + 1)}"
        role        = "manager"
        server_type = var.managers.server_type
        ip          = "10.0.0.${i + 2}"
      }
    ],
    [
      for i in range(var.workers.server_count) : {
        name        = "worker-${format("%02d", i + 1)}"
        role        = "worker"
        server_type = var.workers.server_type
        role        = "controller"
        ip          = "10.0.0.${i + 10}"
      }
    ]
  ])
  managers = tolist([for s in local.servers : s if s.role == "manager"])
  workers  = tolist([for s in local.servers : s if s.role == "worker"])
}
