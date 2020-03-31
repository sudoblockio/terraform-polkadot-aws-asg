
module "network" {
  source = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
}

module "lb" {
  source     = "github.com/insight-w3f/terraform-polkadot-aws-api-lb.git?ref=master"
  subnet_ids = module.network.public_subnets
  vpc_id     = module.network.vpc_id
}

variable "public_key" {}

module "defaults" {
  source = "../.."

  environment = "uat"
  namespace   = "kusama"
  stage       = "test"

  public_key             = var.public_key
  relay_node_ip          = "1.2.3.4"
  relay_node_p2p_address = "stuff.things"
  security_groups        = [module.network.sentry_security_group_id]
  subnet_ids             = module.network.public_subnets
  lb_target_group_arn    = module.lb.lb_target_group_arn
}

