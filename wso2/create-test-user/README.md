# Create Test Users in WSO2

Create users for DFSP simulators in WSO2. This is part of the simulator "onboarding"

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | Passwrod to use when configuring WSO2 | `string` | `"admin"` | no |
| admin\_user | Username to use when configuring WSO2 | `string` | `"admin"` | no |
| extgw\_admin\_port | Port number for External GW admin service | `number` | `9443` | no |
| extgw\_fqdn | FQDN of Internal GW service | `string` | n/a | yes |
| extgw\_state | State of External GW Helm deployment | `string` | `"notused"` | no |
| extgw\_token\_service\_port | Port number for External GW token service | `number` | `8243` | no |
| test\_user\_details | map of user details | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| client-basic-auth-headers | auth header for test user usage |
| client-ids | key for test user usage |
| client-secrets | secret for test user usage |

