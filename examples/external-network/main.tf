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

module "network" {
  source           = "github.com/geometry-labs/terraform-polkadot-aws-network.git?ref=main"
  api_enabled      = true
  num_azs          = 2
  network_settings = local.network_settings
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "builder"
  vpc_id = module.network.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
  }]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
  }]
}

variable "public_key" {}

resource "random_pet" "this" {}

module "defaults" {
  source = "../.."

  name = "external-${random_pet.this.id}"

  create_security_group = false

  public_key              = var.public_key
  subnet_ids              = module.network.public_subnets
  vpc_id                  = module.network.vpc_id
  build_security_group_id = module.sg.security_group_id
  build_subnet_id         = module.network.public_subnets[0]
  build_vpc_id            = module.sg.security_group_vpc_id
  security_groups         = [module.network.api_security_group_id]

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  network_settings = local.network_settings

  depends_on = [module.network, module.sg]
}
