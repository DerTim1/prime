terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.32.2"
    }
  }
}

# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "td" {
  name       = "td@lukes"
  public_key = file("../ssh/td.pub")
}

resource "hcloud_network" "local" {
  name     = "network"
  ip_range = "10.11.0.0/16"
}

resource "hcloud_network_subnet" "local-12" {
  type         = "cloud"
  network_id   = hcloud_network.local.id
  network_zone = "eu-central"
  ip_range     = "10.11.12.0/24"
}

module "prim-prod-gateway-1" {
  source = "./../modules/clustermember/"

  server_name = "tokyo"

  network_id = hcloud_network.local.id
  subnet = hcloud_network_subnet.local-12
  private_ip4 = "10.11.12.1"

  ssh_keys = [hcloud_ssh_key.td.id]
}

module "prim-prod-clustermember-1" {
  source = "./../modules/clustermember/"

  server_name = "rio"

  network_id = hcloud_network.local.id
  subnet = hcloud_network_subnet.local-12
  private_ip4 = "10.11.12.11"

  ssh_keys = [hcloud_ssh_key.td.id]
}

module "prim-prod-clustermember-2" {
  source = "./../modules/clustermember/"

  server_name = "helsinki"

  network_id = hcloud_network.local.id
  subnet = hcloud_network_subnet.local-12
  private_ip4 = "10.11.12.12"

  ssh_keys = [hcloud_ssh_key.td.id]
}

module "prim-prod-clustermember-3" {
  source = "./../modules/clustermember/"

  server_name = "denver"

  network_id = hcloud_network.local.id
  subnet = hcloud_network_subnet.local-12
  private_ip4 = "10.11.12.13"

  ssh_keys = [hcloud_ssh_key.td.id]
}

module "prim-prod-clustermember-4" {
  source = "./../modules/clustermember/"

  server_name = "stockholm"

  network_id = hcloud_network.local.id
  subnet = hcloud_network_subnet.local-12
  private_ip4 = "10.11.12.14"

  ssh_keys = [hcloud_ssh_key.td.id]
}

output "gateway_ip4" {
  value = module.prim-prod-gateway-1.ipv4_address
}

output "gateway_ip6" {
  value = module.prim-prod-gateway-1.ipv6_address
}
