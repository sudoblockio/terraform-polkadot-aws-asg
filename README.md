# terraform-polkadot-aws-asg

## Features

This module sets up an autoscaling group on AWS with a launch configuration that is populated with an AMI produced from a packer build all wrapped in a single terraform module. 

## Terraform Versions

For Terraform v0.12.0+

## Usage

See the `examples` directory for usage. 

```hcl-terraform
module "network" {
  source = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
}

module "lb" {
  source     = "github.com/insight-w3f/terraform-polkadot-aws-api-lb.git?ref=master"
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

- [terraform-packer-build](https://github.com/insight-infrastructure/terraform-packer-build.git) ![](https://img.shields.io/github/v/release/insight-infrastructure/terraform-packer-build?style=svg)
- [terraform-polkadot-user-data](https://github.com/insight-w3f/terraform-polkadot-user-data.git) ![](https://img.shields.io/github/v/release/insight-w3f/terraform-polkadot-user-data?style=svg)
- [terraform-null-label](github.com/robc-io/terraform-null-label) ![](https://img.shields.io/github/v/release/robc-io/terraform-null-label?style=svg)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| null | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| chain | Which Polkadot chain to join | `string` | `"kusama"` | no |
| cluster\_name | The name of the k8s cluster | `string` | `""` | no |
| consul\_enabled | Bool to use when Consul is enabled | `bool` | `false` | no |
| create | Bool to create the resources | `bool` | `true` | no |
| desired\_capacity | The desired capacity of asg | `string` | `2` | no |
| id | The id to give the ami | `string` | `""` | no |
| instance\_type | Instance type | `string` | `"i3.large"` | no |
| key\_name | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| lb\_target\_group\_arn | ID of the lb target group | `string` | n/a | yes |
| lc\_name | The name to give the launch configuration - defaults to 'name' | `string` | `""` | no |
| logging\_filter | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| max\_size | The max size of asg | `string` | `10` | no |
| min\_size | The min size of asg | `string` | `0` | no |
| name | The name to give the ASG and associated resources | `string` | `""` | no |
| node\_exporter\_hash | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| node\_exporter\_password | Password for node exporter | `string` | `"node_exporter_password"` | no |
| node\_exporter\_url | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| node\_exporter\_user | User for node exporter | `string` | `"node_exporter_user"` | no |
| num\_instances | Number of instances for ASG | `number` | `1` | no |
| polkadot\_client\_hash | SHA256 hash of Polkadot client binary | `string` | `"c34d63e5d80994b2123a3a0b7c5a81ce8dc0f257ee72064bf06654c2b93e31c9"` | no |
| polkadot\_client\_url | URL to Polkadot client binary | `string` | `"https://github.com/w3f/polkadot/releases/download/v0.7.32/polkadot"` | no |
| project | Name of the project for node name | `string` | `"project"` | no |
| prometheus\_enabled | Bool to use when Prometheus is enabled | `bool` | `false` | no |
| public\_key | The public ssh key | `string` | n/a | yes |
| relay\_node\_ip | Internal IP of Polkadot relay node | `string` | `""` | no |
| relay\_node\_p2p\_address | P2P address of Polkadot relay node | `string` | `""` | no |
| security\_groups | The ids of the security groups | `list(string)` | n/a | yes |
| ssh\_user | Username for SSH | `string` | `"ubuntu"` | no |
| subnet\_ids | The ids of the subnets to deploy into | `list(string)` | n/a | yes |
| tags | Tags to give resource | `map(string)` | `{}` | no |
| telemetry\_url | WSS URL for telemetry | `string` | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | n/a |
| autoscaling\_group\_id | n/a |
| autoscaling\_group\_name | n/a |
| id | n/a |
| name | n/a |
| tags | n/a |
| user\_data | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.