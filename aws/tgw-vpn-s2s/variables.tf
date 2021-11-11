variable "p2p_tran_gw_name" {
  description = "name for trans gw"
  type        = string
  default     = "Transit GW for p2p vpn"
}

variable "tags" {
  description = "Map of custom tags for the provisioned resources"
  type        = map
  default     = {}
}

variable "cgw_bgp_asn" {
  description = "The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)."
  type        = string
}

variable "cgw_ip_address" {
  description = "IP address of the client VPN endpoint"
  type        = string
}

variable "vpn_cidr_block" {
  description = "VPN CIDR block"
  type        = string
}

variable "static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively. Static routes must be used for devices that don't support BGP"
  type        = bool
  default     = false
}

variable "pm4ml_routes_table_names" {
  description = "List of Route Table Names to add tgw route"
  type        = list(string)
  default     = []
}

variable "static_routes_destinations" {
  description = "List of CIDRs to be routed into the VPN tunnel."
  type        = list
  default     = []
}

variable "default_route_table_association" {
  description = "Boolean flag for toggling the default route table association"
  default     = "disable"
}

variable "default_route_table_propagation" {
  description = "Boolean flag for toggling the propagation of routes in the default route table"
  default     = "disable"
}

variable "transit_gateway_default_route_table_association" {
  default = false
}

variable "transit_gateway_default_route_table_propagation" {
  default = false
}


variable "tunnel1_inside_cidr" {
  description = "Inside tunnel 1 CIDR, a size /30 CIDR block from the 169.254.0.0/16 range"
  default     = "169.254.6.0/30"
}

variable "tunnel2_inside_cidr" {
  description = "Inside tunnel 2 CIDR, a size /30 CIDR block from the 169.254.0.0/16 range"
  default     = "169.254.7.0/30"
}

/* variable "tunnel1_preshared_key" {
  description = "Will be stored in the state as plaintext. Must be between 8 & 64 chars and can't start with zero(0). Allowed characters are alphanumeric, periods(.) and underscores(_)"
}

variable "tunnel2_preshared_key" {
  description = "Will be stored in the state as plaintext. Must be between 8 & 64 chars and can't start with zero(0). Allowed characters are alphanumeric, periods(.) and underscores(_)"
} */

variable "k3svpc" {
  description = "K3S vpc name attachements"
  type        = list(string)
  default     = []
}

variable "phase1_vpn_config" {
  type = map(string)
}

variable "phase2_vpn_config" {
  type = map(string)
}