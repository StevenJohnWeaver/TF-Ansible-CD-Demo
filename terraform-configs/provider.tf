# provider.tf
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# main.tf (modify ssh_key resource)
resource "ibm_is_ssh_key" "ssh_key" {
  name       = "web-app-ssh-key"
  public_key = var.ssh_public_key_content # Use the content variable
}
