/**
 * # Create Test Users in WSO2
 *
 * Create users for DFSP simulators in WSO2. This is part of the simulator "onboarding"
 *
 */

resource "null_resource" "create_artifacts_return_credentials" {
  for_each = var.test_user_details

  provisioner "local-exec" {
    command = <<EOT
echo '{"host":"${var.extgw_fqdn}","admin_port":"${var.extgw_admin_port}","service_port":"${var.extgw_token_service_port}","admin_user":"${var.admin_user}","admin_pass":"${var.admin_password}","account_name":"${each.value.sim_name}","account_pass":"${each.value.sim_password}","api_list":"${each.value.subscribe_to_api_list}"}' | ${path.module}/scripts/provision_test_artifacts.sh
EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo RESOURCE DESTRUCTION NOT IMPLEMENTED. SKIPPING"
  }

  triggers = {
    random = uuid()
  }
}
