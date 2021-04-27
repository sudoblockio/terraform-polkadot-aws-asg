variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

variable "public_key" {}

resource "random_pet" "this" {}

module "defaults" {
  source     = "../.."
  name       = random_pet.this.id
  public_key = var.public_key
}
