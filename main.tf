locals {
  id   = var.id == "" ? random_pet.this.id : var.id
  name = var.name == "" ? random_pet.this.id : var.name
}

resource "random_pet" "this" {
  length = 2
}

variable "create" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

//    "5500", # Polkadot health check
//    "9933", # Polkadot RPC Port
//    "9944", # Polkadot WS Port
//    "5501", # Kusama health check
//    "9934", # Kusama RPC Port
//    "9945", # Kusama WS Port

variable "network_settings" {
  description = "Map of network settings to apply. Use either this or set individual variables."
  type = map(object({
    name                = string
    shortname           = string
    api_health          = string
    polkadot_prometheus = string
    json_rpc            = string
    ws_rpc              = string
  }))
  default = null
}

// If the network map is not supplied, fall back to running on supplied ports which
// default to polkadot.
locals {
  network_settings = var.network_settings == null ? { network = {
    name                = var.network_name
    shortname           = var.network_stub
    api_health          = var.health_check_port
    polkadot_prometheus = var.polkadot_prometheus_port
    json_rpc            = var.rpc_api_port
    ws_rpc              = var.wss_api_port
  } } : var.network_settings
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

#########
# Network
#########
variable "subnet_ids" {
  description = "The ids of the subnets to deploy into"
  type        = list(string)
  default     = null
}

variable "security_groups" {
  description = "The ids of the security groups. Blank to create SG."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = ""
}

data "aws_region" "this" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "this" {
  vpc_id     = var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id
  depends_on = [data.aws_vpc.default]
}

locals {
  vpc_id     = data.aws_subnet_ids.this.vpc_id
  subnet_ids = var.subnet_ids == null ? tolist(data.aws_subnet_ids.this.ids) : var.subnet_ids
}

