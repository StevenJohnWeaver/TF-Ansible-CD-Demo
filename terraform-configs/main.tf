# Configure the AWS provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  
  # Recommended for production: use shared credentials file or IAM roles
  # shared_credentials_file = "~/.aws/credentials"
  # profile                 = "default"
}

# --- AWS VPC (Virtual Private Cloud) ---
# This resource creates a new Virtual Private Cloud network.
resource "aws_vpc" "web_app_vpc" {
  cidr_block = "10.0.0.0/16" # Defines the IP address range for the VPC
  tags = {
    Name = "web-app-demo-vpc"
  }
}

# --- AWS Subnet ---
# A subnet within the VPC. Instances will be launched into this.
resource "aws_subnet" "web_app_subnet" {
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = "10.0.1.0/24" # Defines the IP address range for the subnet
  availability_zone = "${var.aws_region}a" # Assign to a specific AZ (e.g., us-east-1a)
  map_public_ip_on_launch = true # Automatically assign public IP to instances in this subnet

  tags = {
    Name = "web-app-demo-subnet"
  }
}

# --- AWS Internet Gateway ---
# Allows communication between your VPC and the internet.
resource "aws_internet_gateway" "web_app_igw" {
  vpc_id = aws_vpc.web_app_vpc.id
  tags = {
    Name = "web-app-demo-igw"
  }
}

# --- AWS Route Table ---
# Directs network traffic, including traffic to the internet.
resource "aws_route_table" "web_app_route_table" {
  vpc_id = aws_vpc.web_app_vpc.id

  # Route for internet access
  route {
    cidr_block = "0.0.0.0/0" # All traffic
    gateway_id = aws_internet_gateway.web_app_igw.id
  }

  tags = {
    Name = "web-app-demo-rt"
  }
}

# --- AWS Route Table Association ---
# Associates the route table with your subnet.
resource "aws_route_table_association" "web_app_rta" {
  subnet_id      = aws_subnet.web_app_subnet.id
  route_table_id = aws_route_table.web_app_route_table.id
}

# --- AWS Security Group ---
# Acts as a virtual firewall for your EC2 instance to control inbound/outbound traffic.
resource "aws_security_group" "web_app_sg" {
  name        = "web-app-demo-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.web_app_vpc.id

  # Inbound Rule: Allow HTTP (Port 80) from anywhere
  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: Allow SSH (Port 22) from anywhere (CAUTION: highly insecure for production!)
  ingress {
    description = "Allow SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # **CHANGE THIS IN PRODUCTION** to your specific IP range!
  }

  # Outbound Rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-app-demo-sg"
  }
}

# --- AWS Key Pair ---
# Used for SSH access to your EC2 instance.
resource "aws_key_pair" "web_app_ssh_key" {
  key_name   = "web-app-demo-key" # This name will appear in AWS console
  public_key = var.ssh_public_key_content
}

# --- AWS EC2 Instance ---
# Your virtual server (web server)
resource "aws_instance" "web_server" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.web_app_subnet.id
  
  # Associate the security group
  vpc_security_group_ids = [aws_security_group.web_app_sg.id] 
  
  # Associate the SSH key pair
  key_name      = aws_key_pair.web_app_ssh_key.key_name

  # Optional: User data to run commands on instance launch
  # This example installs Apache and creates a simple index.html
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "<h1>Hello from your EC2 Web Server!</h1>" > /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  tags = {
    Name = "web-server-demo"
  }
}

# --- AWS Elastic IP (EIP) ---
# A static public IP address for your EC2 instance.
resource "aws_eip" "web_server_fip" {
  instance = aws_instance.web_server.id
  vpc      = true # Important: must be true for VPC-associated EIPs

  tags = {
    Name = "web-server-fip"
  }
}

# --- Output the Public IP Address ---
output "web_server_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_eip.web_server_fip.public_ip
}
