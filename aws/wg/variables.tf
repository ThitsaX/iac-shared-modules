variable "ami_id" {
  description = "Id of Amazon Image to use"
}
variable "instance_type" {
  description = "Size of the EC2 instance"
}
variable "ssh_key_name" {
  description = "SSH key name used to provision this server"
}
variable "security_groups" {
  description = "security groups attached to this server"
}
variable "subnet_id" {
  description = "Id of the subnet used by this instance"
}
variable "tags" {
  description = "Any additional tags that we might want to pass on"
  default     = { NAME = "Wireguard" }
}
variable "ssh_key" {
  description = "private key used to access this server"
}
