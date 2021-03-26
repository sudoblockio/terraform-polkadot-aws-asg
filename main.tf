data "aws_region" "this" {}

resource "null_resource" "requirements" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${path.module}/ansible/requirements.yml -f"
  }
}

resource "random_pet" "this" {
  length = 2
}

locals {
  id   = var.id == "" ? random_pet.this.id : var.id
  name = var.name == "" ? random_pet.this.id : var.name

  network_settings = var.network_settings == null ? { network = {
    name                = var.network_name
    shortname           = var.network_stub
    api_health          = var.health_check_port
    polkadot_prometheus = var.polkadot_prometheus_port
    json_rpc            = var.rpc_api_port
    ws_rpc              = var.wss_api_port
  } } : var.network_settings
}

module "packer" {
  create = var.create

  source = "github.com/geometry-labs/terraform-packer-build.git?ref=main"

  //  packer_config_path = "${path.module}/packer.json" # .pkr.hcl
  packer_config_path = "${path.module}/packer.pkr.hcl"
  timestamp_ui       = true
  vars = {
    vpc_id    = var.build_vpc_id == "" ? var.vpc_id : var.build_vpc_id
    subnet_id = var.build_subnet_id == "" ? var.subnet_ids[0] : var.build_subnet_id

    id                     = local.id
    skip_health_check      = var.skip_health_check
    network_settings       = jsonencode(local.network_settings)
    aws_region             = data.aws_region.this.name
    module_path            = path.module
    node_exporter_user     = var.node_exporter_user
    node_exporter_password = var.node_exporter_password
    //    ssh_user                      = var.ssh_user
    project                       = var.project
    instance_count                = "library"
    polkadot_binary_url           = var.polkadot_client_url
    polkadot_binary_checksum      = "sha256:${var.polkadot_client_hash}"
    node_exporter_binary_url      = var.node_exporter_url
    node_exporter_binary_checksum = "sha256:${var.node_exporter_hash}"
    polkadot_restart_enabled      = false
    default_telemetry_enabled     = var.default_telemetry_enabled
    telemetry_url                 = var.telemetry_url
    logging_filter                = var.logging_filter
    consul_datacenter             = data.aws_region.this.name
    consul_enabled                = var.consul_enabled
    prometheus_enabled            = var.prometheus_enabled
    retry_join                    = "provider=aws tag_key=\"k8s.io/cluster/${var.cluster_name}\" tag_value=owned"
    aws_access_key_id             = var.sync_aws_access_key_id
    aws_secret_access_key         = var.sync_aws_secret_access_key
    sync_bucket_uri               = var.sync_bucket_uri
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
  source              = "github.com/geometry-labs/terraform-polkadot-user-data.git?ref=main"
  cloud_provider      = "aws"
  type                = "library"
  consul_enabled      = var.consul_enabled
  prometheus_enabled  = var.prometheus_enabled
  prometheus_user     = var.node_exporter_user
  prometheus_password = var.node_exporter_password
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

  spot_price = "1"

  name    = local.name
  lc_name = var.lc_name == "" ? local.name : var.lc_name

  user_data = module.user_data.user_data

  key_name = var.key_name == "" ? join("", aws_key_pair.this.*.key_name) : var.key_name

  image_id = data.aws_ami.packer.id

  instance_type        = var.instance_type
  security_groups      = var.create_security_group ? concat(var.security_groups, aws_security_group.this.*.id) : var.security_groups
  iam_instance_profile = var.iam_instance_profile

  root_block_device = [
    {
      volume_size = var.root_volume_size
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

  target_group_arns = concat(values(aws_lb_target_group.rpc)[*].arn, values(aws_lb_target_group.wss)[*].arn)

  tags_as_map = var.tags
}

//resource "aws_autoscaling_attachment" "this" {
//  autoscaling_group_name = module.asg.this_autoscaling_group_id
//  alb_target_group_arn   = var.lb_target_group_arn
//}
