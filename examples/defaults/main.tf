variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}

resource "random_pet" "this" { length = 1 }

module "defaults" {
  source     = "../.."
  name       = "defaults-${random_pet.this.id}"
  public_key = var.public_key
}
