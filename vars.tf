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

variable "my_public_ssh_key" {
  type        = string
  sensitive   = true
  description = "Your public SSH key that will be used to access the servers"
}

variable "my_ip_addresses" {
  type = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
  description = "Your public IP addresses for port whitelist via the Hetzner firewall configuration"
}

variable "managers_server_type" {
  type        = string
  description = "Type of server for the swarm manager"
}

variable "managers_count" {
  type        = number
  description = "Number of swarm managers"
}

variable "workers_server_type" {
  type        = string
  description = "Type of server for the swarm workers"
}

variable "workers_count" {
  type        = number
  description = "Number of swarm workers"
}

variable "lb_type" {
  description = "Server type of load balancer"
  default     = null
  type        = string
}

variable "lb_target" {
  description = "Choose manager or workers as target of load balancer"
  default     = null
  type        = string
}
