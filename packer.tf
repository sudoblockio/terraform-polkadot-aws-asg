# Builder
variable "build_vpc_id" {
  description = "VPC to build the image in. Must have public subnet - Omit if running cluster deployed in in public subnets."
  type        = string
  default     = ""
}

variable "build_subnet_id" {
  description = "The subnet to build the image in.  Must be public - Omit if running cluster deployed in in public subnets. "
  type        = string
  default     = ""
}

variable "build_security_group_id" {
  description = "The security group to use to build image."
  type        = string
  default     = ""
}

variable "additional_build_security_group_ids" {
  description = "Additional security groups to use to build image."
  type        = list(string)
  default     = [""]
}

variable "packer_build_role_arn" {
  description = "The role arn the packer build should use to build the image."
  type        = string
  default     = ""
}

# Enable Flags
variable "node_exporter_enabled" {
  description = "Bool to use when node exporter is enabled"
  type        = bool
  default     = false
}

variable "health_check_enabled" {
  description = "Bool to enable client health check agent"
  type        = bool
  default     = false
}

variable "consul_enabled" {
  description = "Bool to use when Consul is enabled"
  type        = bool
  default     = false
}

variable "source_of_truth_enabled" {
  description = "Bool to use when SOT is enabled"
  type        = bool
  default     = false
}

variable "prometheus_enabled" {
  description = "Bool to use when Prometheus is enabled"
  type        = bool
  default     = false
}

variable "hardening_enabled" {
  description = "Runs a series of linux hardening playbooks - ansible-collection-hardening"
  type        = bool
  default     = false
}

# Node Exporter
variable "node_exporter_user" {
  description = "User for node exporter"
  type        = string
  default     = "node_exporter_user"
}

variable "node_exporter_password" {
  description = "Password for node exporter"
  type        = string
  default     = "node_exporter_password"
}

variable "node_exporter_url" {
  description = "URL to Node Exporter binary"
  type        = string
  default     = "https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"
}

variable "node_exporter_hash" {
  description = "SHA256 hash of Node Exporter binary"
  type        = string
  default     = "b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"
}

# Substrate Client
variable "polkadot_client_url" {
  description = "URL to Polkadot client binary"
  type        = string
  default     = "https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"
}

variable "polkadot_client_hash" {
  description = "SHA256 hash of Polkadot client binary"
  type        = string
  default     = "0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"
}

variable "project" {
  description = "Name of the project for node name"
  type        = string
  default     = "project"
}

variable "logging_filter" {
  description = "String for polkadot logging filter"
  type        = string
  default     = "sync=trace,afg=trace,babe=debug"
}

variable "telemetry_url" {
  description = "WSS URL for telemetry"
  type        = string
  default     = ""
}

variable "default_telemetry_enabled" {
  description = ""
  type        = bool
  default     = true
}

variable "base_path" {
  description = "Base path for Substrate"
  type        = string
  default     = ""
}

variable "polkadot_additional_common_flags" {
  description = "Additonal common flags for substrate"
  type        = string
  default     = ""
}

variable "polkadot_additional_validator_flags" {
  description = "Additonal common flags for validator"
  type        = string
  default     = ""
}


variable "ssh_user" {
  description = "Username for SSH"
  type        = string
  default     = "ubuntu"
}


variable "consul_version" {
  type        = string
  description = "Consul version number to install"
  default     = "1.9.4"
}

variable "consul_gossip_key" {
  type        = string
  description = "Consul gossip encryption key"
  default     = ""
}

variable "consul_auto_encrypt_enabled" {
  description = "Bool to enable Consul auto-encrypt"
  type        = bool
  default     = false
}

variable "consul_connect_enabled" {
  description = "Bool to enable Consul Connect"
  type        = bool
  default     = false
}

variable "consul_acl_enable" {
  description = "Bool to enable Consul ACLs"
  type        = bool
  default     = false
}

variable "consul_acl_datacenter" {
  description = "Authoritative Consul ACL datacenter"
  type        = string
  default     = ""
}

variable "consul_acl_token" {
  description = "Consul ACL token"
  type        = string
  default     = ""
}

variable "consul_tls_source_dir" {
  description = "Path to TLS files"
  type        = string
  default     = ""
}

variable "consul_tls_ca_filename" {
  description = "Filename of Consul CA"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "The name of the k8s cluster"
  type        = string
  default     = ""
}

variable "sync_aws_access_key_id" {
  description = "AWS access key ID for SoT sync"
  type        = string
  default     = ""
}

variable "sync_aws_secret_access_key" {
  description = "AWS access key for SoT sync"
  type        = string
  default     = ""
}

variable "sync_bucket_name" {
  description = "S3 bucket URI for SoT sync"
  type        = string
  default     = ""
}

variable "sync_bucket_arn" {
  description = "S3 bucket arn for SoT sync"
  type        = string
  default     = ""
}

variable "sync_bucket_kms_key_arn" {
  description = "KMS key used to decrypt S3 bucket for SoT sync"
  type        = string
  default     = ""
}

resource "null_resource" "requirements" {
  triggers = {
    time = timestamp()
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${path.module}/ansible/requirements.yml -f"
  }
}

module "packer" {
  source = "github.com/geometry-labs/terraform-packer-build.git?ref=v0.1.0"

  create             = var.create && var.ami_id == ""
  packer_config_path = "${path.module}/packer.pkr.hcl"
  timestamp_ui       = true

  vars = {
    vpc_id             = var.build_vpc_id == "" ? local.vpc_id : var.build_vpc_id
    subnet_id          = var.build_subnet_id == "" ? local.subnet_ids[0] : var.build_subnet_id
    security_group_ids = var.build_security_group_id != "" && var.additional_build_security_group_ids != [""] ? join(",", distinct(compact(concat([var.build_security_group_id], var.additional_build_security_group_ids)))) : ""

    id                = local.id
    deployed_networks = join("\n", [for network in local.network_settings : network["shortname"]])
    instance_type     = "asg"
    aws_region        = data.aws_region.this.name
    module_path       = path.module
    role_arn          = var.packer_build_role_arn

    # Enable Flags
    node_exporter_enabled  = var.node_exporter_enabled
    health_check_enabled   = var.health_check_enabled
    this_skip_health_check = var.skip_health_check
    consul_enabled         = var.consul_enabled
    use_source_of_truth    = var.source_of_truth_enabled
    prometheus_enabled     = var.prometheus_enabled
    hardening_enabled      = var.hardening_enabled

    # Node Exporter
    node_exporter_user            = var.node_exporter_user
    node_exporter_password        = var.node_exporter_password
    node_exporter_binary_url      = var.node_exporter_url
    node_exporter_binary_checksum = "sha256:${var.node_exporter_hash}"

    # Substrate Client
    polkadot_binary_url      = var.polkadot_client_url
    polkadot_binary_checksum = "sha256:${var.polkadot_client_hash}"

    polkadot_restart_enabled = false

    network_settings = jsonencode(local.network_settings)

    project                   = var.project
    instance_count            = "library"
    logging_filter            = var.logging_filter
    telemetry_url             = var.telemetry_url
    default_telemetry_enabled = var.default_telemetry_enabled
    base_path                 = var.base_path

    # Validator
    polkadot_additional_common_flags    = var.polkadot_additional_common_flags
    polkadot_additional_validator_flags = var.polkadot_additional_validator_flags

    # SOT
    sync_bucket_name = var.sync_bucket_name

    # Consul
    consul_datacenter           = data.aws_region.this.name
    consul_version              = var.consul_version
    retry_join                  = "provider=aws tag_key=\"k8s.io/cluster/${var.cluster_name}\" tag_value=owned"
    consul_gossip_key           = var.consul_gossip_key
    consul_auto_encrypt_enabled = var.consul_auto_encrypt_enabled
    consul_tls_src_files        = var.consul_tls_source_dir
    consul_tls_ca_crt           = var.consul_tls_ca_filename
    consul_connect_enabled      = var.consul_connect_enabled
    consul_acl_enable           = var.consul_acl_enable
    consul_acl_datacenter       = var.consul_acl_datacenter
    consul_acl_token            = var.consul_acl_token

  }
}
# Instance profile for AWS, keys otherwise
//    aws_access_key_id             = var.sync_aws_access_key_id
//    aws_secret_access_key         = var.sync_aws_secret_access_key

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