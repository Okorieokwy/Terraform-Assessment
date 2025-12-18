# 1. Virtual Private Cloud (VPC)

provider "aws" {
  region = var.region
}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "techcorp-vpc"
  }
}

# Internet Gateway (IGW)
# This is the "door" that allows the VPC to talk to the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "techcorp-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

# 4. Private Subnets
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = false

  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = false

  tags = {
    Name = "techcorp-private-subnet-2"
  }
}

# --- NETWORKING PART 2: ROUTING & NAT ---

# ELASTIC IPs (Static IPs for the NAT Gateways)
resource "aws_eip" "nat_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_2" {
  domain = "vpc"
}

# NAT GATEWAYS (Allow private subnets to talk to the internet)
# CRITICAL: These must live in the PUBLIC subnets
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id
  tags = { Name = "techcorp-nat-1" }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id
  tags = { Name = "techcorp-nat-2" }
}

# ROUTE TABLES
# Public Route Table (Traffic -> Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "techcorp-public-rt" }
}

# Private Route Table 1 (Traffic -> NAT 1)
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
  tags = { Name = "techcorp-private-rt-1" }
}

# Private Route Table 2 (Traffic -> NAT 2)
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
  tags = { Name = "techcorp-private-rt-2" }
}

# ROUTE TABLE ASSOCIATIONS (Connecting Subnets to Tables)
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}
# --- SECURITY GROUPS ---

# BASTION SG (Allows SSH from YOU)
resource "aws_security_group" "bastion_sg" {
  name        = "techcorp-bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. WEB SERVER SG (Allows HTTP from World, SSH from Bastion)
resource "aws_security_group" "web_sg" {
  name        = "techcorp-web-sg"
  description = "Allow HTTP/HTTPS and SSH from Bastion"
  vpc_id      = aws_vpc.main.id

  # HTTP from Anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from Anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from Bastion ONLY (Security Group Chaining)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DATABASE SG (Allows MySQL from Web SG, SSH from Bastion)
resource "aws_security_group" "db_sg" {
  name        = "techcorp-db-sg"
  description = "Allow DB access from Web Servers"
  vpc_id      = aws_vpc.main.id

  # MySQL from Web Security Group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Only Web SG can enter
  }
  
  # SSH from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# --- COMPUTE LAYER ---

# Get the latest Amazon Linux 2 AMI dynamically
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Upload your SSH Key to AWS
resource "aws_key_pair" "deployer" {
  key_name   = "techcorp-key"
  public_key = file("${path.module}/techcorp-key.pub")
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "techcorp-bastion"
  }
}

# Web Server 1
resource "aws_instance" "web_1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type_web
  subnet_id              = aws_subnet.private_1.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # Inject the script you wrote earlier
  user_data = file("${path.module}/user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-1"
  }
}

# Web Server 2
resource "aws_instance" "web_2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type_web
  subnet_id              = aws_subnet.private_2.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # Inject the script
  user_data = file("${path.module}/user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-2"
  }
}

#  Database Server
resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type_db
  subnet_id              = aws_subnet.private_1.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  # Inject the DB script
  user_data = file("${path.module}/user_data/db_server_setup.sh")

  tags = {
    Name = "techcorp-db"
  }
}
# --- LOAD BALANCER LAYER ---

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "techcorp-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#  Application Load Balancer
resource "aws_lb" "main" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  # IMPORTANT: ALBs must be in Public Subnets
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "techcorp-alb"
  }
}

# 3. Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "techcorp-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Listener (Listens on Port 80 -> Forwards to TG)
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Target Group Attachments (Connecting EC2s to the ALB)
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_2.id
  port             = 80
}