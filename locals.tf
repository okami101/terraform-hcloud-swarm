locals {
  servers = flatten([
    [{
      name        = "manager"
      server_type = var.manager_server_type
      ip          = "10.0.0.2"
    }],
    [
      for i in range(var.workers_count) : {
        name        = "worker-${format("%02d", i + 1)}"
        server_type = var.workers_server_type
        ip          = "10.0.1.${i + 1}"
      }
    ]
  ])
}
