variable "network_ipv4_cidr" {
  description = "The main network cidr that all subnets will be created upon."
  type        = string
  default     = "10.0.0.0/16"
}

variable "server_image" {
  type        = string
  default     = "ubuntu-22.04"
  description = "The default OS image to use for the servers"
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

variable "cluster_user_public_ssh_keys" {
  description = "Your public SSH keys that will be used to access the cluster user on the servers"
  type        = list(string)
  sensitive   = true
  default     = []
}

variable "hcloud_ssh_keys" {
  description = "List of names of hcloud SSH keys that already exist in the hetzner environment and will be used to access the server via the image default user like root"
  default     = []
  type        = list(string)
}

variable "my_ip_addresses" {
  description = "Your public IP addresses for port whitelist via the Hetzner firewall configuration"
  type        = list(string)
  sensitive   = true
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "docker_config" {
  type        = any
  default     = {}
  description = "Custom docker configuration."
}

variable "nodes" {
  description = "List of all nodes types to create for swarm cluster. Each type can have a different number of instances."
  type = list(object({
    name        = string
    server_type = string
    location    = string
    count       = number
    ports       = optional(list(string))
    lb_type     = optional(string)
  }))
  default = []
}