variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "this" {}

data "aws_region" "this" {}

module "network" {
  source = "terraform-aws-modules/vpc/aws"

  name = "standalone-${random_pet.this.id}"
  cidr = "10.0.0.0/16"

  azs            = ["${data.aws_region.this.name}a", "${data.aws_region.this.name}b", "${data.aws_region.this.name}c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

variable "public_key" {}

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

module "defaults" {
  source = "../.."

  name = "standalone-${random_pet.this.id}"

  public_key = var.public_key
  subnet_ids = module.network.public_subnets
  vpc_id     = module.network.vpc_id

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  hardening_enabled = true
  network_settings  = local.network_settings

  depends_on = [module.network] # Needed so VPC is created before the vpc data source in the module
}
