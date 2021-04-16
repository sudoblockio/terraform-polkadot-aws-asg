# terraform-polkadot-aws-asg

## Features

This module sets up an autoscaling group on AWS with a launch configuration that is populated with an AMI produced from a packer build all wrapped in a single terraform module. 

## Terraform Versions

For Terraform v0.12.0+

## Usage

See the `examples` directory for usage. 

```hcl-terraform
module "network" {
  source = "github.com/geometry-labs/terraform-polkadot-aws-network.git?ref=master"
}

module "lb" {
  source     = "github.com/geometry-labs/terraform-polkadot-aws-api-lb.git?ref=master"
  subnet_ids = module.network.public_subnets
  vpc_id     = module.network.vpc_id
}

variable "public_key" {}

module "defaults" {
  source = "../.."

  environment = "uat"
  namespace   = "kusama"
  stage       = "test"

  public_key             = var.public_key
  relay_node_ip          = "1.2.3.4"
  relay_node_p2p_address = "stuff.things"
  security_groups        = [module.network.sentry_security_group_id]
  subnet_ids             = module.network.public_subnets
  lb_target_group_arn    = module.lb.lb_target_group_arn
}
```

## Examples

- [defaults](https://github.com/robc-io/terraform-polkadot-aws-asg/tree/master/examples/defaults)

## Dependencies 

- [terraform-packer-build](https://github.com/geometry-labs/terraform-packer-build.git) ![](https://img.shields.io/github/v/release/geometry-labs/terraform-packer-build?style=svg)
- [terraform-polkadot-user-data](https://github.com/geometry-labs/terraform-polkadot-user-data.git) ![](https://img.shields.io/github/v/release/geometry-labs/terraform-polkadot-user-data?style=svg)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | ~> 3.8.0 |
| <a name="module_packer"></a> [packer](#module\_packer) | github.com/geometry-labs/terraform-packer-build.git?ref=main |  |
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | github.com/geometry-labs/terraform-polkadot-user-data.git?ref=main |  |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.api_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.describe_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.api_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.api_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.rpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.wss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.rpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.wss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [null_resource.requirements](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_ami.packer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.describe_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID to use in autoscaling group. Blank to build from packer. | `string` | `""` | no |
| <a name="input_build_subnet_id"></a> [build\_subnet\_id](#input\_build\_subnet\_id) | The subnet to build the image in.  Must be public - Omit if running cluster deployed in in public subnets. | `string` | `""` | no |
| <a name="input_build_vpc_id"></a> [build\_vpc\_id](#input\_build\_vpc\_id) | VPC to build the image in. Must have public subnet - Omit if running cluster deployed in in public subnets. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the k8s cluster | `string` | `""` | no |
| <a name="input_consul_enabled"></a> [consul\_enabled](#input\_consul\_enabled) | Bool to use when Consul is enabled | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | Bool to create the resources | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | n/a | `bool` | `false` | no |
| <a name="input_default_telemetry_enabled"></a> [default\_telemetry\_enabled](#input\_default\_telemetry\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired capacity of asg | `string` | `2` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Port number for the health check | `string` | `"5500"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The instance profile to associate with the asg - leasve blank to create one regionally scoped. | `string` | `""` | no |
| <a name="input_id"></a> [id](#input\_id) | The id to give the ami | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type | `string` | `"i3.large"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| <a name="input_lc_name"></a> [lc\_name](#input\_lc\_name) | The name to give the launch configuration - defaults to 'name' | `string` | `""` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The max size of asg | `string` | `10` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The min size of asg | `string` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to give the ASG and associated resources | `string` | `""` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Which Polkadot chain to join | `string` | `"kusama"` | no |
| <a name="input_network_settings"></a> [network\_settings](#input\_network\_settings) | Map of network settings to apply. Use either this or set individual variables. | `map(map(string))` | `null` | no |
| <a name="input_network_stub"></a> [network\_stub](#input\_network\_stub) | The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3) | `string` | `"ksmcc3"` | no |
| <a name="input_node_exporter_hash"></a> [node\_exporter\_hash](#input\_node\_exporter\_hash) | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| <a name="input_node_exporter_password"></a> [node\_exporter\_password](#input\_node\_exporter\_password) | Password for node exporter | `string` | `"node_exporter_password"` | no |
| <a name="input_node_exporter_url"></a> [node\_exporter\_url](#input\_node\_exporter\_url) | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| <a name="input_node_exporter_user"></a> [node\_exporter\_user](#input\_node\_exporter\_user) | User for node exporter | `string` | `"node_exporter_user"` | no |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | Number of instances for ASG | `number` | `1` | no |
| <a name="input_packer_build_role_arn"></a> [packer\_build\_role\_arn](#input\_packer\_build\_role\_arn) | The role arn the packer build should use to build the image. | `string` | `""` | no |
| <a name="input_polkadot_client_hash"></a> [polkadot\_client\_hash](#input\_polkadot\_client\_hash) | SHA256 hash of Polkadot client binary | `string` | `"0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"` | no |
| <a name="input_polkadot_client_url"></a> [polkadot\_client\_url](#input\_polkadot\_client\_url) | URL to Polkadot client binary | `string` | `"https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"` | no |
| <a name="input_polkadot_prometheus_port"></a> [polkadot\_prometheus\_port](#input\_polkadot\_prometheus\_port) | Port number for the Prometheus Metrics exporter built into the Polkadot client | `string` | `"9610"` | no |
| <a name="input_project"></a> [project](#input\_project) | Name of the project for node name | `string` | `"project"` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Bool to use when Prometheus is enabled | `bool` | `false` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The public ssh key | `string` | `""` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | A path to the public key | `string` | `""` | no |
| <a name="input_relay_node_ip"></a> [relay\_node\_ip](#input\_relay\_node\_ip) | Internal IP of Polkadot relay node | `string` | `""` | no |
| <a name="input_relay_node_p2p_address"></a> [relay\_node\_p2p\_address](#input\_relay\_node\_p2p\_address) | P2P address of Polkadot relay node | `string` | `""` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Size in GB for root volume | `string` | `"256"` | no |
| <a name="input_rpc_api_port"></a> [rpc\_api\_port](#input\_rpc\_api\_port) | Port number for the JSON RPC API | `string` | `"9933"` | no |
| <a name="input_security_group_cidr_blocks"></a> [security\_group\_cidr\_blocks](#input\_security\_group\_cidr\_blocks) | If create\_security\_group enabled, incoming cidr blocks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_security_group_open_ports"></a> [security\_group\_open\_ports](#input\_security\_group\_open\_ports) | If create\_security\_group enabled, and no network\_settings blob is supplied, a list of ports to open. | `list(string)` | <pre>[<br>  "5500",<br>  "9933",<br>  "9944",<br>  "5501",<br>  "9934",<br>  "9945"<br>]</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The ids of the security groups | `list(string)` | `[]` | no |
| <a name="input_skip_health_check"></a> [skip\_health\_check](#input\_skip\_health\_check) | Bool to skip the health check and give requests while syncing | `bool` | `false` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Username for SSH | `string` | `"ubuntu"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The ids of the subnets to deploy into | `list(string)` | n/a | yes |
| <a name="input_sync_aws_access_key_id"></a> [sync\_aws\_access\_key\_id](#input\_sync\_aws\_access\_key\_id) | AWS access key ID for SoT sync | `string` | `""` | no |
| <a name="input_sync_aws_secret_access_key"></a> [sync\_aws\_secret\_access\_key](#input\_sync\_aws\_secret\_access\_key) | AWS access key for SoT sync | `string` | `""` | no |
| <a name="input_sync_bucket_uri"></a> [sync\_bucket\_uri](#input\_sync\_bucket\_uri) | S3 bucket URI for SoT sync | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to give resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_url"></a> [telemetry\_url](#input\_telemetry\_url) | WSS URL for telemetry | `string` | `""` | no |
| <a name="input_use_external_lb"></a> [use\_external\_lb](#input\_use\_external\_lb) | Bool to switch between public (true) or private (false) | `bool` | `true` | no |
| <a name="input_use_lb"></a> [use\_lb](#input\_use\_lb) | Bool to enable use of load balancer | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |
| <a name="input_wss_api_port"></a> [wss\_api\_port](#input\_wss\_api\_port) | Port number for the Websockets API | `string` | `"9944"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | n/a |
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | n/a |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | n/a |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | n/a |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | n/a |
| <a name="output_lb_rpc_target_group_arn"></a> [lb\_rpc\_target\_group\_arn](#output\_lb\_rpc\_target\_group\_arn) | n/a |
| <a name="output_lb_rpc_target_group_id"></a> [lb\_rpc\_target\_group\_id](#output\_lb\_rpc\_target\_group\_id) | n/a |
| <a name="output_lb_wss_target_group_arn"></a> [lb\_wss\_target\_group\_arn](#output\_lb\_wss\_target\_group\_arn) | n/a |
| <a name="output_lb_wss_target_group_id"></a> [lb\_wss\_target\_group\_id](#output\_lb\_wss\_target\_group\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | n/a |
| <a name="output_tags"></a> [tags](#output\_tags) | n/a |
| <a name="output_this_security_group_id"></a> [this\_security\_group\_id](#output\_this\_security\_group\_id) | n/a |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## License

Apache 2 Licensed. See LICENSE for full details.