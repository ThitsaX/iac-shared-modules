variable "id" {
  description = "wireguard account name to use as prefix"
  type        = string
}

variable "wireguard_address" {
  description = "wireguard server address"
}

variable "ssh_key" {
  description = "SSH Key used to connect to wireguard"
  type        = string
}

variable "dns_server" {
  description = "default DNS server to use"
}


