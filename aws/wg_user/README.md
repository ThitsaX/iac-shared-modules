# VPN User account Creation

> NOTE: this is experimental and is currently not used

Create Wireguard profiles for each user that requires VPN access

Uses an inline provider to create the profiles

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dns\_server | default DNS server to use | `any` | n/a | yes |
| id | wireguard account name to use as prefix | `string` | n/a | yes |
| ssh\_key | SSH Key used to connect to wireguard | `string` | n/a | yes |
| wireguard\_address | wireguard server address | `any` | n/a | yes |

## Outputs

No output.

