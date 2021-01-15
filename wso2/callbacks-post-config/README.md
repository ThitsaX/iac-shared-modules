# WSO2 Internal Gateway Simulator Post Install Configuration

Configure APIs on the Internal Gateway for each of the provided simulators

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | WSO2 environment name | `string` | `"mojaloop"` | no |
| fspiop\_version | Version of fspiop to use | `string` | `"1.1"` | no |
| intgw\_fqdn | FQDN of Internal GW service | `string` | n/a | yes |
| intgw\_rest\_port | Port number for Interal GW ReST service | `number` | `9843` | no |
| intgw\_state | State of Internal GW Helm deployment | `string` | `"notused"` | no |
| intgw\_token\_port | Port number for Interal GW Token service | `number` | `8843` | no |
| password | Passwrod to use when configuring WSO2 | `string` | `"admin"` | no |
| test\_user\_details | map of test account details | `map(any)` | n/a | yes |
| user | Username to use when configuring WSO2 | `string` | `"admin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| complete | IDs of last job in this module. Can be used to for flow control |

