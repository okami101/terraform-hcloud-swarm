variable "server_image" {
  type        = string
  default     = "ubuntu-22.04"
  description = "The default OS image to use for the servers"
}

variable "server_location" {
  type        = string
  default     = "nbg1"
  description = "The default location where to create hcloud resources"
}

variable "network_zone" {
  description = "The network zone where to attach hcloud resources"
  type        = string
  default     = "eu-central"
}

variable "server_timezone" {
  type        = string
  default     = null
  description = "The default timezone to use for the servers"
}

variable "server_locale" {
  type        = string
  default     = null
  description = "The default locale to create hcloud servers"
}

variable "server_packages" {
  description = "Default packages to install on cloud init"
  type        = list(string)
  default     = []
}

variable "ssh_port" {
  description = "Default SSH port to use for node access"
  type        = number
  default     = null
}

variable "cluster_name" {
  type        = string
  default     = "swarm"
  description = "Will be used to create the hcloud servers as a hostname prefix and main cluster name for the swarm cluster"
}

variable "cluster_user" {
  type        = string
  default     = "swarm"
  description = "The default non-root user (UID=1000) that will be used to access the servers"
}

variable "my_ssh_key_names" {
  description = "List of hcloud SSH key names that will be used to access the servers"
  type        = list(string)
}

variable "my_public_ssh_keys" {
  description = "Your public SSH keys that will be used to access the servers"
  type        = list(string)
  sensitive   = true
}

variable "my_ip_addresses" {
  type = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
  description = "Your public IP addresses for port whitelist via the Hetzner firewall configuration"
}

variable "managers" {
  type = object({
    server_type = string
    count       = number
    lb_type     = optional(string)
  })
  description = "Type of server for the swarm manager"
}

variable "worker_nodepools" {
  description = "List of all additional worker types to create for swarm cluster. Each type is identified by specific role and can have a different number of instances."
  type = list(object({
    name             = string
    server_type      = string
    private_ip_index = optional(number)
    count            = number
    lb_type          = optional(string)
    volume_size      = optional(number)
    volume_format    = optional(string)
  }))
}
