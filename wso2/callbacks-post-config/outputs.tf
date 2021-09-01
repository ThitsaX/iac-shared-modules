output "complete" {
  description = "IDs of last job in this module. Can be used to for flow control"
  value = {
    for instance in null_resource.callback:
    instance.id => instance.id
  }
}

