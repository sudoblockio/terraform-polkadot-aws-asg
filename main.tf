data "aws_region" "this" {}

resource "null_resource" "requirements" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${path.module}/ansible/requirements.yml"
  }
}

resource "random_pet" "this" {
  length = 2
}

locals {
  id   = var.id == "" ? random_pet.this.id : var.id
  name = var.name == "" ? random_pet.this.id : var.name
}

module "packer" {
  create = var.create

  source = "github.com/insight-infrastructure/terraform-aws-packer-ami.git?ref=master"

  packer_config_path = "${path.module}/packer.json"
  timestamp_ui       = true
  vars = {
    id = local.id

    aws_region  = data.aws_region.this.name,
    module_path = path.module,
    node_exporter_user : var.node_exporter_user,
    node_exporter_password : var.node_exporter_password,
    chain : var.network_name,
    ssh_user : var.ssh_user,
    project : var.project,
    polkadot_binary_url : var.polkadot_client_url,
    polkadot_binary_checksum : "sha256:${var.polkadot_client_hash}",
    node_exporter_binary_url : var.node_exporter_url,
    node_exporter_binary_checksum : "sha256:${var.node_exporter_hash}",
    polkadot_restart_enabled : true,
    polkadot_restart_minute : "50",
    polkadot_restart_hour : "10",
    polkadot_restart_day : "1",
    polkadot_restart_month : "*",
    polkadot_restart_weekday : "*",
    telemetry_url : var.telemetry_url,
    logging_filter : var.logging_filter,
    relay_ip_address : var.relay_node_ip,
    relay_p2p_address : var.relay_node_p2p_address,
    consul_datacenter : data.aws_region.this.name,
    consul_enabled : var.consul_enabled,
    prometheus_enabled : var.prometheus_enabled,
    retry_join : "\"provider=aws tag_key='k8s.io/cluster/${var.cluster_name}' tag_value=owned\""
  }
}

// Was having issues in some regions so put in a sleep to fix
resource "null_resource" "wait" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  depends_on = [module.packer]
}

data "aws_ami" "packer" {
  most_recent = true

  filter {
    name   = "tag:Id"
    values = [local.id]
  }

  owners = ["self"]

  depends_on = [module.packer.packer_command, null_resource.wait]
}

module "user_data" {
  source              = "github.com/insight-w3f/terraform-polkadot-user-data.git?ref=master"
  cloud_provider      = "aws"
  type                = "library"
  consul_enabled      = var.consul_enabled
  prometheus_enabled  = var.prometheus_enabled
  prometheus_user     = var.node_exporter_user
  prometheus_password = var.node_exporter_password
}

resource "aws_key_pair" "this" {
  count      = var.key_name == "" ? 1 : 0
  public_key = var.public_key

  tags = var.tags
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  spot_price = "1"

  name    = local.name
  lc_name = var.lc_name == "" ? local.name : var.lc_name

  user_data = module.user_data.user_data

  key_name = var.key_name == "" ? join("", aws_key_pair.this.*.key_name) : var.key_name

  image_id = data.aws_ami.packer.id

  instance_type        = var.instance_type
  security_groups      = var.security_groups
  iam_instance_profile = aws_iam_instance_profile.this.name

  root_block_device = [
    {
      volume_size = "256"
      volume_type = "gp2"
    }
  ]

  vpc_zone_identifier = var.subnet_ids

  health_check_type = "EC2"
  //  TODO Verify ^^
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  target_group_arns = [aws_lb_target_group.rpc[0].arn, aws_lb_target_group.wss[0].arn]

  tags_as_map = var.tags
}

//resource "aws_autoscaling_attachment" "this" {
//  autoscaling_group_name = module.asg.this_autoscaling_group_id
//  alb_target_group_arn   = var.lb_target_group_arn
//}
