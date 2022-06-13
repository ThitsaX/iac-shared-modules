# Nexus Module

Create Nexus server using EC2 instance.

The module creates an EC2 instance. It configures Nexus using a docker instance.

Configuration is done by Ansible using the roles included in this module.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| null | n/a |
| random | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | AMI to use | `string` | `"ami-0e219142c0bee4a6e"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| docker\_repo\_allowed\_cidr\_blocks | A list of CIDR blocks allowed to connect | `list(string)` | <pre>[<br>  "10.25.0.0/16"<br>]</pre> | no |
| docker\_repo\_listening\_port | n/a | `number` | `8082` | no |
| domain | Base domain | `string` | n/a | yes |
| instance\_type | Elastic cache instance type | `string` | `"t3.medium"` | no |
| key\_name | Key name | `string` | `""` | no |
| name | Name  (e.g. `app` or `bastion`) | `string` | `"nexus"` | no |
| namespace | Namespace. Used to help uniquely name resources | `string` | n/a | yes |
| nexus\_admin\_password | nexus admin password, if blank, random pw will be generated | `string` | `""` | no |
| security\_groups | AWS security group IDs | `list(string)` | n/a | yes |
| ssh\_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | `string` | `"ubuntu"` | no |
| subnets | AWS subnet IDs | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`)` | `map(string)` | `{}` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |
| zone\_id | Route53 DNS Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | Instance ID |
| nexus\_admin\_pw | nexus admin pw |
| nexus\_docker\_repo\_port | nexus docker repo port |
| nexus\_ssh\_private\_key | Private SSH key for Nexus Server |
| nexus\_ssh\_public\_key | Public SSH key for Nexus Server |
| role | Name of AWS IAM Role associated with the instance |
| security\_group\_id | Security group ID |
| server\_hostname | n/a |
| server\_private\_ip | Private IP of nexus server |
| ssh\_user | SSH user |

