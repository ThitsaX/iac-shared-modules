## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_avail\_zones | Availability Zones Used | `any` | n/a | yes |
| aws\_cluster\_name | Name of Cluster | `any` | n/a | yes |
| aws\_elb\_api\_port | Port for AWS ELB | `any` | n/a | yes |
| aws\_subnet\_ids\_public | IDs of Public Subnets | `any` | n/a | yes |
| aws\_vpc\_id | AWS VPC ID | `any` | n/a | yes |
| default\_tags | Tags for all resources | `any` | n/a | yes |
| k8s\_secure\_api\_port | Secure Port of K8S API Server | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_elb\_api\_fqdn | n/a |
| aws\_elb\_api\_id | n/a |

