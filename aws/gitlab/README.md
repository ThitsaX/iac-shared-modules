## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | Base domain | `string` | n/a | yes |
| fqdn | n/a | `any` | n/a | yes |
| gitlab\_runner\_size | Gitlab runner VM size | `string` | n/a | yes |
| namespace | Namespace. Used to help uniquely name resources | `string` | n/a | yes |
| security\_groups | AWS security group IDs | `list(string)` | n/a | yes |
| subnets | AWS subnet IDs | `list(string)` | n/a | yes |
| vpc\_id | VPC ID | `string` | n/a | yes |
| allowed\_cidr\_blocks | A list of CIDR blocks allowed to connect | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ami | AMI to use | `string` | `"ami-0e219142c0bee4a6e"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| instance\_type | Elastic cache instance type | `string` | `"t2.large"` | no |
| key\_name | Key name | `string` | `""` | no |
| name | Name  (e.g. `app` or `bastion`) | `string` | `"gitlab"` | no |
| ssh\_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | `string` | `"ubuntu"` | no |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`)` | `map(string)` | `{}` | no |
| user\_data | User data content | `string` | `""` | no |
| user\_data\_file | User data file | `string` | `"user_data.sh"` | no |
| zone\_id | Route53 DNS Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| ci\_private\_ip | Private IP of GitLab CI server |
| ci\_public\_ip | Public IP of GitLab CI server |
| gitlab\_ssh\_private\_key | Private SSH key for GitLab Server and CI runner |
| gitlab\_ssh\_public\_key | Public SSH key for GitLab Server and CI runner |
| instance\_id | Instance ID |
| role | Name of AWS IAM Role associated with the instance |
| security\_group\_id | Security group ID |
| server\_hostname | n/a |
| server\_private\_ip | Private IP of GitLab server |
| server\_public\_ip | Public IP of GitLab server |
| ssh\_user | SSH user |

