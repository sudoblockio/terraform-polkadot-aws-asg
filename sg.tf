variable "create_security_group" {
  type    = bool
  default = true
}

//variable "p2p_ports" {
//  description = "Additional peer to peer ports"
//  type = list(string)
//  default = ["30333", "51820"]
//}

variable "public_security_group_ports" {
  description = "If create_security_group enabled, and no network_settings blob is supplied, a list of ports to open."
  type        = list(string)
  default     = ["30333", "51820"]
}

resource "aws_security_group" "this" {
  count       = var.create && var.create_security_group ? 1 : 0
  description = "Polkadot API Node Ingress."

  vpc_id = data.aws_subnet_ids.this.vpc_id
  name   = "${var.name}-sg"
  tags   = merge(var.tags, { Name = var.name })
}

variable "security_group_cidr_blocks" {
  description = "If create_security_group enabled, incoming cidr blocks."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

locals {
  security_group_open_ports = distinct(flatten([for net in local.network_settings : [net["api_health"], net["json_rpc"], net["ws_rpc"]]]))
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create && var.create_security_group ? length(local.security_group_open_ports) : 0
  from_port         = local.security_group_open_ports[count.index]
  to_port           = local.security_group_open_ports[count.index]
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.this.*.id)
  cidr_blocks       = var.security_group_cidr_blocks
  type              = "ingress"
}

resource "aws_security_group_rule" "public_ingress" {
  count             = var.create && var.create_security_group ? length(var.public_security_group_ports) : 0
  from_port         = var.public_security_group_ports[count.index]
  to_port           = var.public_security_group_ports[count.index]
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.this.*.id)
  cidr_blocks       = ["0.0.0.0/0"]
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

