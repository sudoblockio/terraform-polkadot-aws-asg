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
  default     = []
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

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

variable "network_settings" {
  description = "Map of network settings to apply. Use either this or set individual variables."
  type        = map(map(string))
  default     = null
}

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

variable "network_stub" {
  description = "The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3)"
  type        = string
  default     = "ksmcc3"
}

variable "rpc_api_port" {
  description = "Port number for the JSON RPC API"
  type        = string
  default     = "9933"
}

variable "wss_api_port" {
  description = "Port number for the Websockets API"
  type        = string
  default     = "9944"
}

variable "health_check_port" {
  description = "Port number for the health check"
  type        = string
  default     = "5500"
}

variable "polkadot_prometheus_port" {
  description = "Port number for the Prometheus Metrics exporter built into the Polkadot client"
  type        = string
  default     = "9610"
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

variable "default_telemetry_enabled" {
  description = ""
  type        = bool
  default     = true
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

variable "sync_bucket_uri" {
  description = "S3 bucket URI for SoT sync"
  type        = string
  default     = ""
}

variable "packer_build_role_arn" {
  description = "The role arn the packer build should use to build the image."
  type        = string
  default     = ""
}