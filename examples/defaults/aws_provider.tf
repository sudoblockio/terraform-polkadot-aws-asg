variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}
