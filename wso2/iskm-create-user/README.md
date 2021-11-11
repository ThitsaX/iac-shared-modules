# Create Test Users in WSO2

Create users in WSO2 ISKM.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | Passwrod to use when configuring WSO2 | `string` | `"admin"` | yes |
| admin\_user | Username to use when configuring WSO2 | `string` | `"admin"` | yes |
| iskm\_admin\_port | Port number for External GW admin service | `number` | `9443` | yes |
| iskm\_fqdn | FQDN of Internal GW service | `string` | n/a | yes |
| iskm\_state | State of External GW Helm deployment | `string` | `"notused"` | no |
| account\_username | Username to create in WSO2 | `string` | n/a | yes |
| account\_password | Password to set | `string` | n/a | yes |
| account\_email | Email to set | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| account_userid | UserID of the user |
| user_created | User is created or not |

