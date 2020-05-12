
module "network" {
  source         = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
  sentry_enabled = true
  num_azs        = 2
}

module "lb" {
  source     = "github.com/insight-w3f/terraform-polkadot-aws-api-lb.git?ref=master"
  subnet_ids = module.network.public_subnets
  vpc_id     = module.network.vpc_id
}

variable "public_key" {}

resource "random_pet" "this" {}

module "defaults" {
  source = "../.."

  name = random_pet.this.id

  //  environment = "uat"
  //  namespace   = "kusama"
  //  stage       = "test"

  public_key          = var.public_key
  security_groups     = [module.network.sentry_security_group_id]
  subnet_ids          = module.network.public_subnets
  lb_target_group_arn = module.lb.lb_target_group_arn
}
