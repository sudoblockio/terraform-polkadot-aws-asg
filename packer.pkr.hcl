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

# template: hcl2_upgrade:4:61: executing "hcl2_upgrade" at <clean_resource_name>: error calling clean_resource_name: unhandled "clean_resource_name" call:
# there is no way to automatically upgrade the "clean_resource_name" call.
# Please manually upgrade to use custom validation rules, `replace(string, substring, replacement)` or `regex_replace(string, substring, replacement)`
# Visit https://packer.io/docs/templates/hcl_templates/variables#custom-validation-rules , https://www.packer.io/docs/templates/hcl_templates/functions/string/replace or https://www.packer.io/docs/templates/hcl_templates/functions/string/regex_replace for more infos.

variable "subnet_id" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "aws_region" {
  type = string
  default = ""
}

//locals {
//  subnet_id = var.subnet_id == "" ? "" :
//}

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

  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Created = "{{isotime}}" # missing `clean_resource_name` # https://github.com/hashicorp/packer/issues/9176
    Distro = "Ubuntu-18.04"
    Id = var.id
    Release = "latest"
  }
}

variable "id" {
  type = string
}

variable "node_exporter_binary_url" {
  type = string
}

variable "node_exporter_password" {
  type = string
}

variable "node_exporter_binary_checksum" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "consul_datacenter" {
  type = string
}

variable "logging_filter" {
  type = string
}

variable "skip_health_check" {
  type = string
}

variable "node_exporter_user" {
  type = string
}

variable "project" {
  type = string
}

variable "prometheus_enabled" {
  type = bool
}

variable "consul_enabled" {
  type = bool
}

variable "default_telemetry_enabled" {
  type = string
}

variable "polkadot_binary_url" {
  type = string
}

variable "polkadot_binary_checksum" {
  type = string
}

variable "polkadot_restart_enabled" {
  type = bool
}

variable "telemetry_url" {
  type = string
}

variable "sync_bucket_uri" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "retry_join" {
  type = string
}

variable "module_path" {
  type = string
}

variable "network_settings" {
  type = string
}

build {
  sources = ["source.amazon-ebs.ubuntu18-ami"]

  provisioner "ansible" {
    extra_arguments = [
      "-e",
      "consul_datacenter=${var.consul_datacenter}",
      "-e",
      "health_check_enabled=${var.skip_health_check}",
      "-e",
      "region=${var.aws_region}",
      "-e",
      "node_exporter_user=${var.node_exporter_user}",
      "-e",
      "node_exporter_password=${var.node_exporter_password}",
      "-e",
      "project=${var.project}",
      "-e",
      "instance_count=${var.instance_count}",
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
      "telemetryUrl=${var.telemetry_url}",
      "-e",
      "default_telemetry_enabled=${var.default_telemetry_enabled}",
      "-e",
      "loggingFilter=${var.logging_filter}",
      "-e",
      "consul_enabled=${var.consul_enabled}",
      "-e",
      "prometheus_enabled=${var.prometheus_enabled}",
      "-e",
      "retry_join_string='${var.retry_join}'",
      "-e",
      "network_settings=\"${var.network_settings}\"",
      "-e",
      "aws_access_key_id=${var.aws_access_key_id}",
      "-e",
      "aws_secret_access_key=${var.aws_secret_access_key}",
      "-e",
      "sync_bucket_uri=${var.sync_bucket_uri}"
    ]
    playbook_file = "${var.module_path}/ansible/main.yml"
    roles_path = "${var.module_path}/ansible/roles"
  }

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}