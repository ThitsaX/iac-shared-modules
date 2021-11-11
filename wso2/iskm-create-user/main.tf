/**
 * # Create Users in WSO2 ISKM
 */

data "external" "create_user" {
  program = ["bash", "provision_test_artifacts.sh"]
  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    host = var.iskm_fqdn
    admin_port = var.iskm_admin_port
    admin_user = var.admin_user
    admin_pass = var.admin_password
    account_username = var.account_username
    account_password = var.account_password
    account_email = var.account_email
  }
  working_dir = "${path.module}/scripts"
}
