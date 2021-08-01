/**
 * # Mojaloop SDK
 *
 * Create EC2 instances in AWS for deploying VMs to host Mock FSP/SDK instances
 *
 */

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "tf_ssh_key" {
  key_name   = "${var.tenant}-${var.environment}-sdk-vm-ssh-key"
  public_key = tls_private_key.tf_ssh_key.public_key_openssh
  tags = {
    Tenant      = var.tenant
    Environment = var.environment
  }
}

resource "tls_private_key" "tf_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "tf_ssh_priv_key" {
  content         = tls_private_key.tf_ssh_key.private_key_pem
  filename        = "${path.module}/tf_ssh_priv_key.pem"
  file_permission = "0600"
}

resource "local_file" "tf_ssh_pub_key" {
  content  = tls_private_key.tf_ssh_key.public_key_pem
  filename = "${path.module}/tf_ssh_pub_key.pem"
}

module "network" {
  source           = "./modules/network"
  subnet_cidrs     = var.subnet_cidrs
  vpc_cidr         = var.vpc_cidr
  allow_ssh_access = var.allow_ssh_access
  allow_cbs_access = var.allow_cbs_access
  allow_sdk_access = var.allow_sdk_access
  allow_k3s_access = var.allow_k3s_access
  tags = {
    Tenant      = var.tenant
    Environment = var.environment
    Module      = "sdk"
  }
}

module "clientnode" {
  source              = "./modules/instances"
  ami                 = var.ami
  vpc_id              = module.network.vpc_id
  subnet_id           = module.network.public_subnet_id
  name                = "mock-fsp"
  environment         = var.environment
  extra_sgs           = [module.network.ssh_security_group_id, module.network.sdk_security_group_id, module.network.cbsadapter_security_group_id]
  extra_packages      = lookup(var.extra_packages, "sdk", "base")
  external_nameserver = var.external_nameserver
  key_pair_name       = aws_key_pair.tf_ssh_key.key_name
  template_filename   = "user_data.sh.tpl"
  instance_count      = var.client_node_count
  domain              = var.domain
  tags = {
    Tenant      = var.tenant
    Environment = var.environment
    Module      = "sdk"
  }
}

module "k3snode" {
  source              = "./modules/instances"
  ami                 = var.k3s_ami
  vpc_id              = module.network.vpc_id
  subnet_id           = module.network.public_subnet_id
  name                = "k3s"
  environment         = var.environment
  extra_sgs           = [module.network.ssh_security_group_id, module.network.kubeapi_security_group_id]
  extra_packages      = lookup(var.extra_packages, "sdk", "base")
  external_nameserver = var.external_nameserver
  key_pair_name       = aws_key_pair.tf_ssh_key.key_name
  template_filename   = "k3s_user_data.sh.tpl"
  instance_count      = var.k3s_node_count
  domain              = var.domain
  tags = {
    Tenant      = var.tenant
    Environment = var.environment
    Module      = "sdk"
  }
}
