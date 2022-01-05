# Automated ISKM for "Business Operations Framework"

Configuration management repo to configure WSO2 Identity Server (with Key Management) to support OAuth2 / OpenID Connect integration for "Business Operations Framework"

## Requirements

| Name | Version |
|------|---------|
| external | ~> 1.2.0 |

## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_service\_provider | Whether or not to create service provider `y` | `string` | `"y"` | no |
| iskm\_fqdn | FQDN of Internal GW service | `string` | n/a | yes |
| iskm\_rest\_port | Port number for External GW ReST service | `number` | `9443` | no |
| iskm\_status | iskm install status | `string` | `"notused"` | no |
| password | Passwrod to use when configuring WSO2 | `string` | `"admin"` | no |
| user | Username to use when configuring WSO2 | `string` | `"admin"` | no |
| callback_url | Callback URL for oAuth | `string` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| consumer-key | key for oauth2/oidc usage |
| consumer-secret | secret for oauth2/oidc usage |

