#####
# asg
#####
variable "min_size" {
  description = "The min size of asg"
  type        = string
  default     = 1
}

variable "max_size" {
  description = "The max size of asg"
  type        = string
  default     = 1
}

variable "desired_capacity" {
  description = "The desired capacity of asg"
  type        = string
  default     = 1
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior.	"
  type        = string
  default     = "10m"
}

variable "iam_instance_profile" {
  description = "The instance profile to associate with the asg - leasve blank to create one regionally scoped."
  type        = string
  default     = ""
}

##########
# Instance
##########
variable "skip_health_check" {
  description = "Bool to skip the health check and give requests while syncing"
  type        = bool
  default     = false
}

variable "envoy_enabled" {
  description = "Configure Envoy proxy for Consul Connect"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "The public ssh key"
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "A path to the public key"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The name of the preexisting key to be used instead of the local public_key_path"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "i3.large"
}

variable "num_instances" {
  description = "Number of instances for ASG"
  type        = number
  default     = 1
}

variable "root_volume_size" {
  description = "Size in GB for root volume"
  type        = string
  default     = "256"
}

variable "ami_id" {
  description = "AMI ID to use in autoscaling group. Blank to build from packer."
  type        = string
  default     = ""
}

variable "spot_price" {
  type    = string
  default = null
}

module "user_data" {
  source              = "github.com/geometry-labs/terraform-polkadot-user-data.git"
  cloud_provider      = "aws"
  type                = "library"
  prometheus_enabled  = var.prometheus_enabled
  prometheus_user     = var.node_exporter_user
  prometheus_password = var.node_exporter_password
  envoy_enabled       = var.envoy_enabled
}

locals {
  public_key = var.public_key_path != "" ? file(var.public_key_path) : var.public_key
}

resource "aws_key_pair" "this" {
  count = var.key_name == "" ? 1 : 0

  key_name   = var.id
  public_key = local.public_key

  tags = var.tags
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.8.0"

  spot_price           = var.spot_price
  name                 = local.name
  lc_name              = var.lc_name == "" ? local.name : var.lc_name
  user_data            = module.user_data.user_data
  key_name             = var.key_name == "" ? join("", aws_key_pair.this.*.key_name) : var.key_name
  image_id             = var.ami_id == "" ? data.aws_ami.packer.id : var.ami_id
  instance_type        = var.instance_type
  security_groups      = var.create_security_group ? concat(var.security_groups, aws_security_group.this.*.id) : var.security_groups
  iam_instance_profile = var.iam_instance_profile == "" ? join("", aws_iam_instance_profile.this.*.name) : var.iam_instance_profile

  root_block_device = [
    {
      volume_size = var.root_volume_size
      volume_type = "gp2"
    }
  ]

  vpc_zone_identifier = local.subnet_ids

  health_check_type         = "EC2"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  target_group_arns = concat(values(aws_lb_target_group.rpc)[*].arn, values(aws_lb_target_group.wss)[*].arn, values(aws_lb_target_group.ext-health)[*].arn)
  tags_as_map       = merge(var.tags, { Name = var.name })
}
