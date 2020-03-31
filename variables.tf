variable "create" {
  description = "Bool to create the resources"
  type        = bool
  default     = true
}

########
# Label
########
variable "environment" {
  description = "The environment"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "The namespace to deploy into"
  type        = string
  default     = "polkadot"
}

variable "stage" {
  description = "The stage of the deployment"
  type        = string
  default     = "test"
}

variable "network_name" {
  description = "The network name, ie kusama / mainnet"
  type        = string
  default     = "kusama"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "insight-w3f"
}

##########
# Instance
##########
variable "public_key" {
  description = "The public ssh key"
  type        = string
}

variable "key_name" {
  description = "The name of the preexisting key to be used instead of the local public_key_path"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "Standard_A2_v2"
}

variable "num_instances" {
  description = "Number of instances for ASG"
  type        = number
  default     = 1
}

#########
# Network
#########
variable "subnet_ids" {
  description = "The ids of the subnets to deploy into"
  type        = list(string)
}

variable "security_groups" {
  description = "The ids of the security groups"
  type        = list(string)
}

variable "lb_target_group_arn" {
  description = "ID of the lb target group"
  type        = string
}

#####
# packer
#####
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

variable "chain" {
  description = "Which Polkadot chain to join"
  type        = string
  default     = "kusama"
}

variable "project" {
  description = "Name of the project for node name"
  type        = string
  default     = "project"
}

variable "ssh_user" {
  description = "Username for SSH"
  type        = string
  default     = "ubuntu"
}

variable "telemetry_url" {
  description = "WSS URL for telemetry"
  type        = string
  default     = "wss://mi.private.telemetry.backend/"
}

variable "logging_filter" {
  description = "String for polkadot logging filter"
  type        = string
  default     = "sync=trace,afg=trace,babe=debug"
}

variable "relay_node_ip" {
  description = "Internal IP of Polkadot relay node"
  type        = string
}

variable "relay_node_p2p_address" {
  description = "P2P address of Polkadot relay node"
  type        = string
}