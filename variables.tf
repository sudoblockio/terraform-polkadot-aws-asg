variable "create" {
  description = "Bool to create the resources"
  type        = bool
  default     = true
}

########
# Label
########
variable "name" {
  description = "The name to give the ASG and associated resources"
  type        = string
  default     = ""
}

variable "lc_name" {
  description = "The name to give the launch configuration - defaults to 'name'"
  type        = string
  default     = ""
}

variable "id" {
  description = "The id to give the ami"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to give resource"
  type        = map(string)
  default     = {}
}


#####
# asg
#####

variable "min_size" {
  description = "The min size of asg"
  type        = string
  default     = 0
}

variable "max_size" {
  description = "The max size of asg"
  type        = string
  default     = 10
}

variable "desired_capacity" {
  description = "The desired capacity of asg"
  type        = string
  default     = 2
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior.	"
  type        = string
  default     = "10m"
}

//
//variable "environment" {
//  description = "The environment"
//  type        = string
//  default     = "dev"
//}
//
//variable "namespace" {
//  description = "The namespace to deploy into"
//  type        = string
//  default     = "polkadot"
//}
//
//variable "stage" {
//  description = "The stage of the deployment"
//  type        = string
//  default     = "test"
//}
//
//variable "network_name" {
//  description = "The network name, ie kusama / mainnet"
//  type        = string
//  default     = "kusama"
//}
//
//variable "owner" {
//  description = "Owner of the infrastructure"
//  type        = string
//  default     = "insight-w3f"
//}

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
  default     = "i3.large"
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

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

##########
# Load Balancer
##########

variable "use_lb" {
  description = "Bool to enable use of load balancer"
  type        = bool
  default     = true
}

variable "use_external_lb" {
  description = "Bool to switch between public (true) or private (false)"
  type        = bool
  default     = true
}

#####
# packer
#####
variable "polkadot_client_url" {
  description = "URL to Polkadot client binary"
  type        = string
  default     = "https://github.com/w3f/polkadot/releases/download/v0.7.32/polkadot"
}

variable "polkadot_client_hash" {
  description = "SHA256 hash of Polkadot client binary"
  type        = string
  default     = "c34d63e5d80994b2123a3a0b7c5a81ce8dc0f257ee72064bf06654c2b93e31c9"
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

variable "network_name" {
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
  default     = ""
}

variable "logging_filter" {
  description = "String for polkadot logging filter"
  type        = string
  default     = "sync=trace,afg=trace,babe=debug"
}

variable "relay_node_ip" {
  description = "Internal IP of Polkadot relay node"
  type        = string
  default     = ""
}

variable "relay_node_p2p_address" {
  description = "P2P address of Polkadot relay node"
  type        = string
  default     = ""
}

variable "consul_enabled" {
  description = "Bool to use when Consul is enabled"
  type        = bool
  default     = false
}

variable "prometheus_enabled" {
  description = "Bool to use when Prometheus is enabled"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "The name of the k8s cluster"
  type        = string
  default     = ""
}
