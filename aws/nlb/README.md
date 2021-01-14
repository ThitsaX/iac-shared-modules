## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_ids | Instance IDs to attach to the target group. | `any` | n/a | yes |
| nlb\_listeners | List of listeners to attach to target groups | `any` | n/a | yes |
| prefix | Naming prefix to use with module resources | `any` | n/a | yes |
| subnet\_id | subnet\_id to attach the NLB to | `any` | n/a | yes |
| tags | Default tags to assign to resources | `map` | `{}` | no |
| vpc\_id | vpc\_id to attach the NLB to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_dns | n/a |
| private\_ip | n/a |
| public\_dns | n/a |
| public\_ip | n/a |

