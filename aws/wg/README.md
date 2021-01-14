# VPN Server

Create EC2 instance that performs the VPN function

Uses an inline provision to deploy  Wireguard

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | Id of Amazon Image to use | `string` | n/a | yes |
| instance\_type | Size of the EC2 instance | `string` | n/a | yes |
| security\_groups | security groups attached to this server | `any` | n/a | yes |
| ssh\_key | private key used to access this server | `any` | n/a | yes |
| ssh\_key\_name | SSH key name used to provision this server | `string` | n/a | yes |
| subnet\_id | Id of the subnet used by this instance | `any` | n/a | yes |
| tags | Any additional tags that we might want to pass on | `map` | <pre>{<br>  "Name": "Wireguard"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| private\_ip | n/a |
| public\_ip | n/a |

