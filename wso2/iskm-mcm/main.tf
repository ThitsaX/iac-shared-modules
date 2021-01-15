/**
 * # Automated ISKM to MCM integration
 *
 *Configuration management repo to configure WSO2 Identity Server (with Key Management) to support OAuth2 integration for MCM
 *
 */

resource "null_resource" "get_secret_and_key" {
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts"
    command     = <<EOT
echo "{\"host\":\"${var.iskm_fqdn}\",\"rest_port\":\"${var.iskm_rest_port}\",\"admin_user\":\"${var.user}\",\"admin_pass\":\"${var.password}\",\"create_service_provider\":\"${var.create_service_provider}\"}" | ./generateMCMConfigKeySecret.sh
EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo RESOURCE DESTRUCTION NOT IMPLEMENTED. SKIPPING"
  }

}
