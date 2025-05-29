# Define the IBM Cloud Provider and specify required version
# This ensures Terraform knows which provider to use and handles compatibility.
terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.57.0" # Always pin to a specific or range of versions
    }
  }
  required_version = ">= 1.0.0" # Specify minimum Terraform CLI version
}

# Configure the IBM Cloud Provider with API Key and Region
# The values for ibmcloud_api_key and region will come from variables,
# which are either set in variables.tf and passed via CLI/env vars,
# or configured directly in HCP Terraform workspace variables.
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# --- VPC (Virtual Private Cloud) ---
# This resource creates a new Virtual Private Cloud network.
resource "ibm_is_vpc" "web_app_vpc" {
  name           = "web-app-demo-vpc"
  resource_group = var.resource_group_name # Assign to a resource group for organization
}

# --- Subnet ---
# A subnet within the VPC where the VSI will reside.
resource "ibm_is_subnet" "web_app_subnet" {
  name            = "web-app-demo-subnet"
  vpc             = ibm_is_vpc.web_app_vpc.id
  zone            = "${var.region}-1" # Example: us-south-1
  ipv4_cidr_block = "10.240.0.0/24" # Choose a non-overlapping CIDR block
  network_acl     = ibm_is_network_acl.web_app_acl.id # Associate with our custom ACL
}

# --- Network ACL (Access Control List) ---
# Defines inbound/outbound rules for traffic on the subnet.
# Crucial for allowing SSH and web traffic.
resource "ibm_is_network_acl" "web_app_acl" {
  vpc  = ibm_is_vpc.web_app_vpc.id
  name = "web-app-demo-acl"

  # Inbound rules
  rules {
    action      = "allow"
    direction   = "inbound"
    source      = "0.0.0.0/0" # Allow from anywhere (for demo, be more restrictive in prod)
    destination = "0.0.0.0/0"
    protocol    = "tcp"
    port_min    = 22 # Allow SSH access
    port_max    = 22
  }
  rules {
    action      = "allow"
    direction   = "inbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    protocol    = "tcp"
    port_min    = 80 # Allow HTTP access (if your app listens on 80)
    port_max    = 80
  }
  rules {
    action      = "allow"
    direction   = "inbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    protocol    = "tcp"
    port_min    = 8080 # Allow your specific app port (e.g., Node.js app)
    port_max    = 8080
  }
  # Add outbound rules if your app needs to connect to specific external services
  rules {
    action      = "allow"
    direction   = "outbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

# --- SSH Key ---
# Imports or creates an SSH key that will be used to access the VSI.
# Using 'var.ssh_public_key_content' is common when managing keys via HCP Terraform.
resource "ibm_is_ssh_key" "web_app_ssh_key" {
  name       = "web-app-demo-key"
  public_key = var.ssh_public_key_content # Content of your public SSH key
}

# --- Virtual Server Instance (VSI) ---
# The actual compute instance where your web application will run.
resource "ibm_is_instance" "web_server" {
  name    = "web-app-demo-vsi"
  image   = "ibm-ubuntu-22-04-1-minimal-amd64-1" # Specify a suitable image ID or name
  profile = "cx2-2x4"                           # Choose an appropriate VSI profile (vCPUs/RAM)
  vpc     = ibm_is_vpc.web_app_vpc.id
  zone    = ibm_is_subnet.web_app_subnet.zone   # Match the subnet's zone
  keys    = [ibm_is_ssh_key.web_app_ssh_key.id] # Attach the SSH key for access

  primary_network_interface {
    subnet = ibm_is_subnet.web_app_subnet.id
    # You can also attach a security group here if preferred over ACLs for instance-level control
    # security_groups = [ibm_is_security_group.web_app_sg.id]
  }
  # For boot volume and data volumes, refer to IBM Cloud docs for more options
}

# --- Floating IP ---
# Assigns a public IP address to the VSI's primary network interface,
# making it accessible from the internet.
resource "ibm_is_floating_ip" "web_server_fip" {
  name    = "web-app-demo-fip"
  target  = ibm_is_instance.web_server.primary_network_interface[0].id
}

# --- Outputs ---
# These values are displayed after 'terraform apply' and can be retrieved
# by CI/CD pipelines (like IBM Cloud CD from HCP Terraform).
output "web_server_ip" {
  description = "The public IP address of the web server VSI."
  value       = ibm_is_floating_ip.web_server_fip.address
}

output "ssh_command" {
  description = "SSH command to connect to the web server VSI."
  value       = "ssh root@${ibm_is_floating_ip.web_server_fip.address}"
}
