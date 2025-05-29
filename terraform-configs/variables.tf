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
