data "amazon-ami" "autogenerated_1" {
  filters = {
    architecture = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
    root-device-type = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners = [
    "099720109477"]
  region = "${var.aws_region}"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "subnet_id" {
  type = string
  default = ""
}

variable "security_group_ids" {
  type = string
  default = ""
}

variable "id" {
  type = string
  default = ""
}

variable "deployed_networks" {
  type = string
  default = ""
}

variable "aws_region" {
  type = string
  default = ""
}

variable "module_path" {
  type = string
  default = ""
}

variable "role_arn" {
  type = string
  default = ""
}

source "amazon-ebs" "ubuntu18-ami" {
  ami_description = "Ubuntu 18.04 AMI configured for polkadot"
  ami_name = "polkadot-ubuntu-{{uuid}}" # missing `clean_resource_name` on isotime # https://github.com/hashicorp/packer/issues/9176
  associate_public_ip_address = true
  instance_type = "t3.small"
  region = var.aws_region

  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

//  source_ami = "{{ data `amazon-ami.autogenerated_1.id` }}"
  ssh_username = "ubuntu"

  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
  security_group_ids = split(",", var.security_group_ids)

  temporary_iam_instance_profile_policy_document {
    Statement {
      Action   = ["ec2:DescribeInstances"]
      Effect   = "Allow"
      Resource = ["*"]
    }
    Version = "2012-10-17"
  }

  assume_role {
    role_arn = var.role_arn
  }

  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Created = "{{isotime}}" # missing `clean_resource_name` # https://github.com/hashicorp/packer/issues/9176
    Distro = "Ubuntu-18.04"
    Id = var.id
    Release = "latest"
  }
}

variable "instance_type" {
  type = string
  default = ""
}

variable "node_exporter_enabled" {
  type = string
  default = ""
}

variable "health_check_enabled" {
  type = string
  default = ""
}

variable "this_skip_health_check" {
  type = string
  default = ""
}

variable "consul_enabled" {
  type = string
  default = ""
}

variable "use_source_of_truth" {
  type = string
  default = ""
}

variable "prometheus_enabled" {
  type = string
  default = ""
}

variable "hardening_enabled" {
  type = string
  default = ""
}

variable "node_exporter_user" {
  type = string
  default = ""
}
variable "node_exporter_password" {
  type = string
  default = ""
}
variable "node_exporter_binary_url" {
  type = string
  default = ""
}
variable "node_exporter_binary_checksum" {
  type = string
  default = ""
}

variable "polkadot_binary_url" {
  type = string
  default = ""
}

variable "polkadot_binary_checksum" {
  type = string
  default = ""
}

variable "polkadot_restart_enabled" {
  type = string
  default = ""
}

variable "network_settings" {
  type = string
  default = ""
}

variable "project" {
  type = string
  default = ""
}

variable "instance_count" {
  type = string
  default = ""
}

variable "logging_filter" {
  type = string
  default = ""
}

variable "telemetry_url" {
  type = string
  default = ""
}

variable "default_telemetry_enabled" {
  type = string
  default = ""
}

variable "base_path" {
  type = string
  default = ""
}

variable "polkadot_additional_common_flags" {
  type = string
  default = ""
}

variable "polkadot_additional_validator_flags" {
  type = string
  default = ""
}

variable "sync_bucket_uri" {
  type = string
  default = ""
}

variable "consul_datacenter" {
  type = string
  default = ""
}

variable "consul_version" {
  type = string
  default = ""
}

variable "retry_join" {
  type = string
  default = ""
}

variable "consul_gossip_key" {
  type = string
  default = ""
}

variable "consul_auto_encrypt_enabled" {
  type = string
  default = ""
}

variable "consul_tls_src_files" {
  type = string
  default = ""
}

variable "consul_tls_ca_crt" {
  type = string
  default = ""
}

variable "consul_connect_enabled" {
  type = string
  default = ""
}

variable "consul_acl_enable" {
  type = string
  default = ""
}

variable "consul_acl_datacenter" {
  type = string
  default = ""
}

variable "consul_acl_token" {
  type = string
  default = ""
}

build {
  sources = ["source.amazon-ebs.ubuntu18-ami"]

  provisioner "ansible" {
    extra_arguments = [
      "-e",
      "deployed_networks='${var.deployed_networks}'",
      "-e",
      "instance_type=${var.instance_type}",
      "-e",
      "region=${var.aws_region}",
      "-e",
      "module_path=${var.module_path}",
      "-e",
      "node_exporter_enabled=${var.node_exporter_enabled}",
      "-e",
      "health_check_enabled=${var.health_check_enabled}",
      "-e",
      "skip_health_check=${var.this_skip_health_check}",
      "-e",
      "consul_enabled=${var.consul_enabled}",
      "-e",
      "use_source_of_truth=${var.use_source_of_truth}",
      "-e",
      "prometheus_enabled=${var.prometheus_enabled}",
      "-e",
      "hardening_enabled=${var.hardening_enabled}",
      "-e",
      "node_exporter_user=${var.node_exporter_user}",
      "-e",
      "node_exporter_password=${var.node_exporter_password}",
      "-e",
      "node_exporter_binary_url=${var.node_exporter_binary_url}",
      "-e",
      "node_exporter_binary_checksum=${var.node_exporter_binary_checksum}",
      "-e",
      "polkadot_binary_url=${var.polkadot_binary_url}",
      "-e",
      "polkadot_binary_checksum=${var.polkadot_binary_checksum}",
      "-e",
      "polkadot_restart_enabled=${var.polkadot_restart_enabled}",
      "-e",
      "network_settings=\"${var.network_settings}\"",
      "-e",
      "project=${var.project}",
      "-e",
      "instance_count=${var.instance_count}",
      "-e",
      "loggingFilter=${var.logging_filter}",
      "-e",
      "telemetryUrl=${var.telemetry_url}",
      "-e",
      "default_telemetry_enabled=${var.default_telemetry_enabled}",
      "-e",
      "base_path=${var.base_path}",
      "-e",
      "polkadot_additional_common_flags=${var.polkadot_additional_common_flags}",
      "-e",
      "polkadot_additional_validator_flags=${var.polkadot_additional_validator_flags}",
      "-e",
      "sync_bucket_uri=${var.sync_bucket_uri}",
      "-e",
      "consul_datacenter=${var.consul_datacenter}",
      "-e",
      "consul_version=${var.consul_version}",
      "-e",
      "retry_join_string='${var.retry_join}'",
      "-e",
      "consul_gossip_key='${var.consul_gossip_key}'",
      "-e",
      "consul_auto_encrypt_enabled='${var.consul_auto_encrypt_enabled}'",
      "-e",
      "consul_tls_src_files=${var.consul_tls_src_files}",
      "-e",
      "consul_tls_ca_crt=${var.consul_tls_ca_crt}",
      "-e",
      "consul_connect_enabled='${var.consul_connect_enabled}'",
      "-e",
      "consul_acl_enable='${var.consul_acl_enable}'",
      "-e",
      "consul_acl_datacenter='${var.consul_acl_datacenter}'",
      "-e",
      "consul_acl_token='${var.consul_acl_token}'"
    ]
    playbook_file = "${var.module_path}/ansible/main.yml"
    roles_path = "${var.module_path}/ansible/roles"
  }

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}
