# Mojaloop SDK

Create EC2 instances in AWS for deploying VMs to host Mock FSP/SDK instances

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_cbs\_access | List of CIDR blocks that can access cbs ports | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| allow\_k3s\_access | List of CIDR blocks that can access k3s kubeapi | `list` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| allow\_sdk\_access | List of CIDR blocks that can access sdk ports | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| allow\_ssh\_access | CIDR block that can access instances via SSH | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ami | AWS Instance type | `string` | `"ami-06fd8a495a537da8b"` | no |
| client | Name of client | `string` | n/a | yes |
| client\_node\_count | Number of client nodes to create with docker-compose | `number` | `1` | no |
| domain | Domain name to create DNS entries | `string` | n/a | yes |
| environment | Name of environment this SDK belongs to | `string` | `"dev"` | no |
| external\_nameserver | DNS resolver address | `string` | `"8.8.8.8"` | no |
| extra\_packages | Additional packages to install for particular module | `map(string)` | <pre>{<br>  "sdk": "wget bind-utils docker nc git"<br>}</pre> | no |
| k3s\_ami | AWS Instance type | `string` | `"ami-06fd8a495a537da8b"` | no |
| k3s\_node\_count | Number of k3s nodes to create | `number` | `0` | no |
| region | AWS region. Changing it will lead to loss of complete stack. | `string` | n/a | yes |
| sdks | A list of maps Mock FSP data. | `list(map(string))` | n/a | yes |
| subnet\_cidrs | CIDR blocks for public and private subnets | `map(string)` | <pre>{<br>  "private": "10.0.2.0/24",<br>  "public": "10.0.1.0/24"<br>}</pre> | no |
| tags | Map of tags to apply to resources created | `map(string)` | `{}` | no |
| vpc\_cidr | CIDR block to allocate the SDK VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| dfsp\_data | JSON object describing the dfsps and their endpoints |
| domain | Base domain into which the VMs and dfsps are created |
| hosts | List of nodes hostnames, json encoded |
| publicIPs | List of nodes public IPs, json encoded |

