variable "tags" {
  description = "Default tags to assign to resources" 
  default     = {}
}

variable "prefix" {
  description = "Naming prefix to use with module resources"  
}

variable "vpc_id" {
  description = "vpc_id to attach the NLB to"
}

variable "subnet_id" {
  description = "subnet_id to attach the NLB to"
}

variable "instance_ids" {
  description = "Instance IDs to attach to the target group."
}

variable "nlb_listeners" {
  description = "List of listeners to attach to target groups"
}

