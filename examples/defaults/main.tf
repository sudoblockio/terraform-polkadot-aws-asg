variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}

resource "random_pet" "this" { length = 1 }

module "defaults" {
  source                  = "../.."
  name                    = "defaults-${random_pet.this.id}"
  public_key              = var.public_key
  build_vpc_id            = "vpc-0f94f09a6b5e07ab7"
  build_subnet_id         = "subnet-05da249cef2bcffec"
  build_security_group_id = "sg-018b4fb87a41b98e8"
}
