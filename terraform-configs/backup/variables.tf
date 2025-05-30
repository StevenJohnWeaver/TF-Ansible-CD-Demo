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

variable "resource_group_name" {
  description = "The name of the IBM Cloud resource group to deploy resources into."
  type        = string
  # You can uncomment and set a default if you want, or leave it for runtime input
  default     = "Default"
}
