variable "server_name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnet" {
  type = object({
    type = string
    network_id = string
    network_zone = string
    ip_range = string
  })
}

variable "private_ip4" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}
