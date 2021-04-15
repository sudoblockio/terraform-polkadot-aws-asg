
# TODO: What is 30333, and 51820

//module "api_node_sg" {
//  source      = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.2.0"
//  name        = var.api_sg_name
//  description = "All traffic"
//
//  create = local.api_enabled
//
//  vpc_id = module.vpc.vpc_id
//  tags = merge({
//    Name : var.api_sg_name
//  }, var.tags)
//
//  ingress_with_source_security_group_id = concat(local.bastion_enabled ? [
//    {
//      rule                     = "ssh-tcp"
//      source_security_group_id = module.bastion_sg.this_security_group_id
//      }] : [], local.monitoring_enabled ? concat([
//      # static rules
//      {
//        from_port                = 9100
//        to_port                  = 9100
//        protocol                 = "tcp"
//        description              = "Node exporter"
//        source_security_group_id = module.monitoring_sg.this_security_group_id
//      },
//      {
//        from_port                = 9323
//        to_port                  = 9323
//        protocol                 = "tcp"
//        description              = "Docker Prometheus Metrics under /metrics endpoint"
//        source_security_group_id = module.monitoring_sg.this_security_group_id
//      }], [
//      # dynamic rules based on Polkadot network
//      for network in var.polkadot_network_settings : {
//        from_port                = network["polkadot_prometheus"]
//        to_port                  = network["polkadot_prometheus"]
//        protocol                 = "tcp"
//        description              = "Client exporter - ${network["name"]}"
//        source_security_group_id = module.monitoring_sg.this_security_group_id
//      }
//    ]) : [], local.hids_enabled ? [
//    {
//      from_port                = 1514
//      to_port                  = 1515
//      protocol                 = "tcp"
//      description              = "wazuh agent ports for "
//      source_security_group_id = module.monitoring_sg.this_security_group_id
//  }] : [])
//
//  ingress_cidr_blocks = local.consul_enabled ? [
//  module.vpc.vpc_cidr_block] : []
//  ingress_rules = local.consul_enabled ? [
//    "consul-tcp",
//    "consul-serf-wan-tcp",
//    "consul-serf-wan-udp",
//    "consul-serf-lan-tcp",
//    "consul-serf-lan-udp",
//    "consul-dns-tcp",
//  "consul-dns-udp"] : []
//
//  ingress_with_cidr_blocks = concat(
//    concat(
//      # static rules
//      [
//        {
//          from_port   = 30333
//          to_port     = 30333
//          protocol    = "tcp"
//          description = ""
//          cidr_blocks = "0.0.0.0/0"
//        },
//        {
//          from_port   = 51820
//          to_port     = 51820
//          protocol    = "udp"
//          description = ""
//          cidr_blocks = "0.0.0.0/0"
//        },
//        ], [
//        # dynamic rules based on Polkadot network
//        for network in var.polkadot_network_settings : {
//          from_port   = network["api_health"]
//          to_port     = network["api_health"]
//          protocol    = "tcp"
//          description = "Health Check - ${network["name"]}"
//          cidr_blocks = "0.0.0.0/0"
//      }],
//      [
//        for network in var.polkadot_network_settings : {
//          from_port   = network["json_rpc"]
//          to_port     = network["json_rpc"]
//          protocol    = "tcp"
//          description = "JSON RPC - ${network["name"]}"
//          cidr_blocks = "0.0.0.0/0"
//      }],0

variable "create_security_group" {
  type    = bool
  default = false
}

resource "aws_security_group" "this" {
  count       = var.create && var.create_security_group ? 1 : 0
  description = "Polkadot API Node Ingress."

  vpc_id = var.vpc_id
  name   = "polkadot-api-sg"
  tags   = merge(var.tags, { Name = var.name })
}

variable "security_group_open_ports" {
  description = "If create_security_group enabled, a list of ports to open."
  type        = list(string)
  default = [
    "5500", # Polkadot health check
    "9933", # Polkadot RPC Port
    "9944", # Polkadot WS Port
    "5501", # Kusama health check
    "9934", # Kusama RPC Port
    "9945", # Kusama WS Port
  ]
}

variable "security_group_cidr_blocks" {
  description = "If create_security_group enabled, incoming cidr blocks."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create && var.create_security_group ? length(var.security_group_open_ports) : 0
  from_port         = var.security_group_open_ports[count.index]
  to_port           = var.security_group_open_ports[count.index]
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.this.*.id)
  cidr_blocks       = var.security_group_cidr_blocks
  type              = "ingress"
}

resource "aws_security_group_rule" "egress" {
  count             = var.create && var.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this.*.id)
}

output "this_security_group_id" {
  value = join("", aws_security_group.this.*.id)
}

