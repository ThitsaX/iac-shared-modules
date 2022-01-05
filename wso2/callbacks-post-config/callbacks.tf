locals {
  callback_env = {
    internal_gateway_hostname            = var.intgw_fqdn
    int_token_gateway_hostname           = var.intgw_token_fqdn
    api_gateway_rest_endpoint_port       = var.intgw_rest_port
    api_gateway_token_endpoint_port      = var.intgw_token_port
    base_api_context                     = "/api/am/publisher/v0.14/apis"
    dcr_api_context                      = "/client-registration/v0.14/register"
    token_api_context                    = "/token"
    api_specification_swagger_files_list = "callback/simulator_${var.fspiop_version}.json"
  }
}

resource "local_file" "sim_api_template" {
  for_each = var.test_user_details
  content         = templatefile("${path.module}/scripts/callbacks.tpl", { sim_name = "${each.value.sim_name}", host = "${each.value.sim_name}", sim_url = "${each.value.sim_callback_url}" })
  filename        = "${path.module}/scripts/callback/${var.environment}-${each.key}.api_template.json"
  file_permission = "0644"
}

resource "null_resource" "callback" { 
  for_each = var.test_user_details
  triggers = {
    id = uuid()
  }
  provisioner "local-exec" {
    command     = "./deploy_api.sh -e ${var.environment}-${each.key} -u ${var.user} -p ${var.password}"
    environment = local.callback_env
    working_dir = "${path.module}/scripts"
  }
  depends_on = [local_file.sim_api_template]
}
