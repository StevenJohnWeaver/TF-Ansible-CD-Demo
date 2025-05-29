# variables.tf
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "ssh_public_key_content" { # Use this name if you're passing content directly
  description = "Content of the SSH public key for VSI access"
  type        = string
  sensitive   = true
}

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
