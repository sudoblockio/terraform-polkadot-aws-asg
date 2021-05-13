# terraform-polkadot-aws-asg

This module sets up a load balanced set of endpoints for the Polkadot blockchain and it's associated parachains on AWS. Components include: 

- AMI produced from a packer build
- Autoscaling group 
- Network load balancer 
- Scaling policies 

The module is intended to be flexible in its configuration parameters allowing users specify networks and securtiy groups while also providing sane defaults for one click deployments. Users then have the option of attaching their own DNS record or with additional configuration, joining to a consul cluster and monitoring with prometheus. 

## Requirements

- Terraform version 0.14+ tested - [Install](https://www.terraform.io/downloads.html)
- Packer version 1.7+ - [Install](https://www.packer.io/downloads)
- Ansible 2.9 - `pip install ansible`
- SSH Keys - `ssh-keygen -b 4096` (Only public required)

## Usage

Steps for running terraform:

1. Install the above [requirements](#requirements)
   
2. Get AWS API keys into environment variables
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

3. Create SSH keys and make note of the path (public_key_path variable) or copy the key material. 

```shell
ssh-keygen -b 4096 -f $HOME/.ssh/<your key name>
cat $HOME/.ssh/<your key name>.pub # this is the `public_key` variable 
```

4. Use this module in your own terraform or modify one of the examples directory. Possible configurations are:

#### Defaults

Minimal defaults example. 

```hcl-terraform
module "defaults" {
  source     = "github.com/geometry-labs/terraform-polkadot-aws-asg"
  name       = "some-name"
  public_key = file(var.public_key_path)
}
```
Deploys in default vpc and creates security group.  For public deployments 

#### External Network with Parachains 

To run additional parachains, complete the below map for `network_settings` to map ports to the associated chain. Ports will then be exposed over the load balancer. 

```hcl
locals {
  network_settings = {
    polkadot = {
      name                = "polkadot"
      shortname           = "polkadot"
      api_health          = "5000"
      polkadot_prometheus = "9610"
      json_rpc            = "9933"
      ws_rpc              = "9944"
    }
    kusama = {
      name                = "kusama"
      shortname           = "ksmcc3"
      api_health          = "5001"
      polkadot_prometheus = "9611"
      json_rpc            = "9934"
      ws_rpc              = "9945"
    }
  }
}

module "network" {
  source           = "github.com/geometry-labs/terraform-polkadot-aws-network.git?ref=main"
  api_enabled      = true
  num_azs          = 2
  network_settings = local.network_settings
}

variable "public_key" {}

resource "random_pet" "this" {}

module "defaults" {
  source = "../.."

  name = "external-${random_pet.this.id}"

  create_security_group = false

  public_key      = var.public_key
  security_groups = [module.network.api_security_group_id]
  subnet_ids      = module.network.public_subnets
  vpc_id          = module.network.vpc_id

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  network_settings = local.network_settings

  depends_on = [module.network]
}
```

## Examples

- [defaults](https://github.com/geometry-labs/terraform-polkadot-aws-asg/tree/master/examples/defaults)

- [spot](https://github.com/geometry-labs/terraform-polkadot-aws-asg/tree/master/examples/spot)

- [external-network](https://github.com/geometry-labs/terraform-polkadot-aws-asg/tree/master/examples/external-network)

- [standalone](https://github.com/geometry-labs/terraform-polkadot-aws-asg/tree/master/examples/standalone)

## Dependencies 

- [terraform-packer-build](https://github.com/geometry-labs/terraform-packer-build.git) ![](https://img.shields.io/github/v/release/geometry-labs/terraform-packer-build?style=svg)
- [terraform-polkadot-user-data](https://github.com/geometry-labs/terraform-polkadot-user-data.git) ![](https://img.shields.io/github/v/release/geometry-labs/terraform-polkadot-user-data?style=svg)

## Known  Issues

- When creating a network within the same module as this one, you need to explicitly put a `depends_on` on the network to make the graph resolve properly or apply it twice. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| null | n/a |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| asg | terraform-aws-modules/autoscaling/aws | ~> 3.8.0 |
| packer | github.com/geometry-labs/terraform-packer-build.git?ref=v0.1.0 |  |
| user_data | github.com/geometry-labs/terraform-polkadot-user-data.git?ref=v0.1.0 |  |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) |
| [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| [aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) |
| [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |
| [aws_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | AMI ID to use in autoscaling group. Blank to build from packer. | `string` | `""` | no |
| build\_subnet\_id | The subnet to build the image in.  Must be public - Omit if running cluster deployed in in public subnets. | `string` | `""` | no |
| build\_vpc\_id | VPC to build the image in. Must have public subnet - Omit if running cluster deployed in in public subnets. | `string` | `""` | no |
| cluster\_name | The name of the k8s cluster | `string` | `""` | no |
| consul\_acl\_datacenter | Authoritative Consul ACL datacenter | `string` | `""` | no |
| consul\_acl\_enable | Bool to enable Consul ACLs | `bool` | `false` | no |
| consul\_acl\_token | Consul ACL token | `string` | `""` | no |
| consul\_auto\_encrypt\_enabled | Bool to enable Consul auto-encrypt | `bool` | `false` | no |
| consul\_connect\_enabled | Bool to enable Consul Connect | `bool` | `false` | no |
| consul\_enabled | Bool to use when Consul is enabled | `bool` | `false` | no |
| consul\_gossip\_key | Consul gossip encryption key | `string` | `""` | no |
| consul\_security\_group | ID of security group to containing Consul | `string` | `null` | no |
| create | Boolean to make module or not | `bool` | `true` | no |
| create\_security\_group | n/a | `bool` | `true` | no |
| default\_telemetry\_enabled | n/a | `bool` | `true` | no |
| desired\_capacity | The desired capacity of asg | `string` | `1` | no |
| enable\_scaling | Bool to enable scaling policy | `bool` | `true` | no |
| health\_check\_port | Port number for the health check | `string` | `"5500"` | no |
| iam\_instance\_profile | The instance profile to associate with the asg - leasve blank to create one regionally scoped. | `string` | `""` | no |
| id | The id to give the ami | `string` | `""` | no |
| instance\_type | Instance type | `string` | `"i3.large"` | no |
| key\_name | The name of the preexisting key to be used instead of the local public\_key\_path | `string` | `""` | no |
| lc\_name | The name to give the launch configuration - defaults to 'name' | `string` | `""` | no |
| logging\_filter | String for polkadot logging filter | `string` | `"sync=trace,afg=trace,babe=debug"` | no |
| max\_size | The max size of asg | `string` | `1` | no |
| min\_size | The min size of asg | `string` | `1` | no |
| name | The name to give the ASG and associated resources | `string` | `""` | no |
| network\_name | Which Polkadot chain to join | `string` | `"kusama"` | no |
| network\_settings | Map of network settings to apply. Use either this or set individual variables. | <pre>map(object({<br>    name                = string<br>    shortname           = string<br>    api_health          = string<br>    polkadot_prometheus = string<br>    json_rpc            = string<br>    ws_rpc              = string<br>  }))</pre> | `null` | no |
| network\_stub | The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3) | `string` | `"ksmcc3"` | no |
| node\_exporter\_hash | SHA256 hash of Node Exporter binary | `string` | `"b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"` | no |
| node\_exporter\_password | Password for node exporter | `string` | `"node_exporter_password"` | no |
| node\_exporter\_url | URL to Node Exporter binary | `string` | `"https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"` | no |
| node\_exporter\_user | User for node exporter | `string` | `"node_exporter_user"` | no |
| num\_instances | Number of instances for ASG | `number` | `1` | no |
| packer\_build\_role\_arn | The role arn the packer build should use to build the image. | `string` | `""` | no |
| polkadot\_client\_hash | SHA256 hash of Polkadot client binary | `string` | `"0b27d0cb99ca60c08c78102a9d2f513d89dfec8dbd6fdeba8b952a420cdc9fd2"` | no |
| polkadot\_client\_url | URL to Polkadot client binary | `string` | `"https://github.com/paritytech/polkadot/releases/download/v0.8.29/polkadot"` | no |
| polkadot\_prometheus\_port | Port number for the Prometheus Metrics exporter built into the Polkadot client | `string` | `"9610"` | no |
| project | Name of the project for node name | `string` | `"project"` | no |
| prometheus\_enabled | Bool to use when Prometheus is enabled | `bool` | `false` | no |
| public\_key | The public ssh key | `string` | `""` | no |
| public\_key\_path | A path to the public key | `string` | `""` | no |
| public\_security\_group\_ports | If create\_security\_group enabled, and no network\_settings blob is supplied, a list of ports to open. | `list(string)` | <pre>[<br>  "30333",<br>  "51820"<br>]</pre> | no |
| relay\_node\_ip | Internal IP of Polkadot relay node | `string` | `""` | no |
| relay\_node\_p2p\_address | P2P address of Polkadot relay node | `string` | `""` | no |
| root\_volume\_size | Size in GB for root volume | `string` | `"256"` | no |
| rpc\_api\_port | Port number for the JSON RPC API | `string` | `"9933"` | no |
| scaling\_cpu\_utilization | The percent CPU utilization for scaling. | `number` | `80` | no |
| security\_group\_cidr\_blocks | If create\_security\_group enabled, incoming cidr blocks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| security\_groups | The ids of the security groups. Blank to create SG. | `list(string)` | `[]` | no |
| skip\_health\_check | Bool to skip the health check and give requests while syncing | `bool` | `false` | no |
| spot\_price | n/a | `string` | `null` | no |
| ssh\_user | Username for SSH | `string` | `"ubuntu"` | no |
| subnet\_ids | The ids of the subnets to deploy into | `list(string)` | `null` | no |
| sync\_aws\_access\_key\_id | AWS access key ID for SoT sync | `string` | `""` | no |
| sync\_aws\_secret\_access\_key | AWS access key for SoT sync | `string` | `""` | no |
| sync\_bucket\_arn | S3 bucket arn for SoT sync | `string` | `""` | no |
| sync\_bucket\_kms\_key\_arn | KMS key used to decrypt S3 bucket for SoT sync | `string` | `""` | no |
| sync\_bucket\_uri | S3 bucket URI for SoT sync | `string` | `""` | no |
| tags | Tags to give resource | `map(string)` | `{}` | no |
| telemetry\_url | WSS URL for telemetry | `string` | `""` | no |
| use\_lb | Bool to enable use of load balancer | `bool` | `true` | no |
| vpc\_id | vpc id | `string` | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |
| wss\_api\_port | Port number for the Websockets API | `string` | `"9944"` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | n/a |
| autoscaling\_group\_id | n/a |
| autoscaling\_group\_name | n/a |
| dns\_name | n/a |
| id | n/a |
| lb\_arn | n/a |
| lb\_id | n/a |
| lb\_rpc\_target\_group\_arn | n/a |
| lb\_rpc\_target\_group\_id | n/a |
| lb\_wss\_target\_group\_arn | n/a |
| lb\_wss\_target\_group\_id | n/a |
| name | n/a |
| public\_ips | n/a |
| tags | n/a |
| this\_security\_group\_id | n/a |
| user\_data | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## License

Apache 2 Licensed. See LICENSE for full details.