terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.32.2"
    }
  }
}

resource "hcloud_server" "vm" {
  name        = "${var.server_name}"
  server_type = "cpx31"
  image       = "ubuntu-20.04"
  location    = "fsn1"

  network {
    network_id = var.network_id
    ip         = var.private_ip4
  }

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    var.subnet
  ]

  ssh_keys = var.ssh_keys
}
