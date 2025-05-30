# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources into (e.g., us-east-1, us-west-2)."
  type        = string
  default     = "us-east-1" 
}

# AWS Authentication Credentials
variable "aws_access_key" {
  description = "AWS access key for authentication."
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging its value
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication."
  type        = string
  sensitive   = true # Mark as sensitive
}

# EC2 Instance Configuration
variable "aws_ami_id" {
  description = "The AMI ID for the EC2 instance (e.g., Amazon Linux 2 HVM)."
  type        = string
  # IMPORTANT: Replace this with a valid AMI ID for your chosen region!
  # Example for Amazon Linux 2 (us-east-1): ami-0abcdef1234567890
  default     = "ami-0abcdef1234567890" 
}

variable "aws_instance_type" {
  description = "The instance type for the EC2 instance (e.g., t2.micro)."
  type        = string
  default     = "t2.micro" 
}

# SSH Public Key for Instance Access
variable "ssh_public_key_content" {
  description = "Public SSH key content to inject into the EC2 instance for access."
  type        = string
  sensitive   = true # Mark as sensitive
}

# Optional: You can add more variables for CIDR blocks, specific ports, etc.
