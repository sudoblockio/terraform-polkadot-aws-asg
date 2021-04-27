variable "aws_region" {}

provider "aws" {
  region = var.aws_region
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
    }
    kusama = {
      name                = "kusama"
      shortname           = "ksmcc3"
      api_health          = "5001"
      polkadot_prometheus = "9611"
      json_rpc            = "9934"
      ws_rpc              = "9945"
    }
  }
}

module "network" {
  source                    = "github.com/geometry-labs/terraform-polkadot-aws-network.git?ref=main"
  api_enabled               = true
  num_azs                   = 2
  polkadot_network_settings = local.network_settings
}

variable "public_key" {}

resource "random_pet" "this" {}

module "defaults" {
  source = "../.."

  name = random_pet.this.id

  create_security_group = false

  public_key      = var.public_key
  security_groups = [module.network.api_security_group_id]
  subnet_ids      = module.network.public_subnets
  vpc_id          = module.network.vpc_id

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  network_settings = local.network_settings
}
