variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "this" {
  length = 2
}

locals {
  network_settings = {
    polkadot = {
      name                = "polkadot"
      shortname           = "polkadot"
      api_health          = "5000"
      polkadot_prometheus = "9610"
      json_rpc            = "9933"
      ws_rpc              = "9944"
      json_envoy          = "21000"
      ws_envoy            = "21001"
    }
    kusama = {
      name                = "kusama"
      shortname           = "ksmcc3"
      api_health          = "5001"
      polkadot_prometheus = "9611"
      json_rpc            = "9934"
      ws_rpc              = "9945"
      json_envoy          = "21000"
      ws_envoy            = "21001"
    }
  }
}

variable "public_key" {}

module "defaults" {
  source = "../.."

  name = "spot-${random_pet.this.id}"

  public_key = var.public_key

  spot_price = "1"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  network_settings        = local.network_settings
  build_vpc_id            = "vpc-0f94f09a6b5e07ab7"
  build_subnet_id         = "subnet-05da249cef2bcffec"
  build_security_group_id = "sg-018b4fb87a41b98e8"
}
