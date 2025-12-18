variable "region" {
  description = "AWS Region to deploy to"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  default     = "10.0.0.0/16"
}

# --- Public Subnet CIDRs ---
variable "public_subnet_1_cidr" {
  description = "CIDR for Public Subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for Public Subnet 2"
  default     = "10.0.2.0/24"
}

# --- Private Subnet CIDRs ---
variable "private_subnet_1_cidr" {
  description = "CIDR for Private Subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for Private Subnet 2"
  default     = "10.0.4.0/24"
}

# --- Availability Zones ---
variable "az_1" {
  description = "Availability Zone 1"
  default     = "us-east-1a"
}

variable "az_2" {
  description = "Availability Zone 2"
  default     = "us-east-1b"
}
variable "my_ip" {
  description = "Your personal IP address for SSH access (e.g., x.x.x.x/32)"
  type        = string
  # REPLACE THIS with your actual IP, e.g., "41.10.20.30/32"
  default     = "0.0.0.0/0" 
}
# --- COMPUTE VARIABLES ---

variable "instance_type_web" {
  description = "Instance type for web servers"
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Instance type for database"
  default     = "t3.small"
}

variable "public_key" {
  description = "Your Public SSH Key"
  # PASTE YOUR KEY inside the quotes below
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClUa3k82LObpbx8G+YU3tPDPASEuEUs98pwjR4PsU6n6Koljbr7B5DCrVpKfQ8++hUJ2IRHjAJ08qCFwi/NWeNiDzo9RYD2nYvPAFFYrmy495DMNnJ/yAUJB+483RqOmCGlZFZnynm4s1g4o5Qy6Fzj1cYnnXpXUWATh5fwB+FXmIlksKF/rojH+6aUvxFgdrwUAdq99qoChEiBQLlKTuvM1Hq/UeoKuZDKJwmZPSdBbYROB836n5EJthDbN8qtP6LWmqHG/tkZxrPFBLaWpnEQo3VAZ/e8IFvF4YHG6BVJDuL+/dyV1FkyjHspQFeVZbARH8qjWLws0hJ3uXVYafgJQb1Dj83swPaqmplauEMIuM+qDD4VXo3DZMa++pxcraP6uB/kYX+iJd85mKT4Ya/7n5E0bqgkWNPTB9k1lIKIkknuhToGFz+HuQ3AJUVMQNT2iwklO5wyEc4BFP8O/S2p3vjdSEqxRNYEBvR6qj5VXvwCKT+wTQLGVDgQIqgco9t1n9WKUUQoUVNCBV8RBWk1iuHWm+DERZxzmd+WyWFe0bfw82NehgTeEOQLgBQe5T/tLT0GMqhoLn5+fE/cs1476IkkJN1wJLIzcPaNwVyGDPHD6oDN4xx9pGyBvjgRSV0pUoWwPKHgqSSDIsKf0RNgCzse+uagWinH6C1DXgzdQ== hp@DESKTOP-QG644FB"
}