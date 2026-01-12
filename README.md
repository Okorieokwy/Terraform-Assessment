# Terraform-Assessment
# TechCorp Infrastructure Deployment - Month 1 Assessment

This repository contains the Terraform configuration for deploying a secure, high-availability Three-Tier Architecture on AWS for TechCorp.

## Project Overview
The infrastructure provisions a Virtual Private Cloud (VPC) with public and private subnets across two Availability Zones. It includes:
* **Networking:** VPC, Public/Private Subnets, Internet Gateway, NAT Gateways, and Route Tables.
* **Security:** Security Groups for Bastion, Web Servers, Database, and Load Balancer.
* **Compute:**
    * **Bastion Host:** For secure SSH access.
    * **Web Servers:** 2x EC2 instances (Apache) in private subnets.
    * **Database Server:** 1x EC2 instance (PostgreSQL) in a private subnet.
* **Load Balancing:** Application Load Balancer (ALB) distributing traffic to web servers.

## Prerequisites
Before deploying, ensure you have the following installed and configured:
* [Terraform](https://www.terraform.io/downloads) (v1.0+)
* [AWS CLI](https://aws.amazon.com/cli/) (configured with valid credentials)
* An SSH Key Pair generated locally (`~/.ssh/techcorp_key`)

## Directory Structure
```text
terraform-assessment/
├── main.tf                 # Core infrastructure resources (VPC, EC2, SG, ALB)
├── variables.tf            # Configuration variables
├── outputs.tf              # Outputs (Load Balancer DNS, Bastion IP, etc.)
├── terraform.tfvars.example # Example variable values
├── user_data/              # Startup scripts
│   ├── web_server_setup.sh
│   └── db_server_setup.sh
├── evidence/               # Screenshots of deployment proof
└── README.md               # Project documentation
```

## Deployment Instructions

1.  Initialize Terraform
        Download the required AWS providers.
        ```bash
        terraform init
        ```

2.  Plan the Deployment
        Review the resources that will be created.
        ```bash
        terraform plan
        ```

3.  Apply the Configuration
        Provision the infrastructure.
        ```bash
        terraform apply -auto-approve
        ```

## Accessing the Infrastructure

### 1. Web Application
Copy the `load_balancer_dns_name` from the Terraform outputs and paste it into your browser.
* **URL:** `http://<your-alb-dns-name>`

### 2. SSH Access (via Bastion)
The private servers are not directly accessible. You must "jump" through the Bastion host.

To access the Web Server:
```bash
ssh -i ~/.ssh/techcorp_key -J ec2-user@<BASTION_PUBLIC_IP> ec2-user@<WEB_PRIVATE_IP>
```

To access the Database Server:
```bash
ssh -i ~/.ssh/techcorp_key -J ec2-user@<BASTION_PUBLIC_IP> ec2-user@<DB_PRIVATE_IP>
```

---

## Deployment Evidence
> Note: Evidence screenshots are located in the `evidence/` directory.

1. Terraform Plan  
     ![Terraform Plan](evidence/1-terraform-plan.jpg)

2. Terraform Apply Completion  
     ![Terraform Apply](evidence/2-terraform-apply.jpg)

3. AWS Console Resources  
     ![AWS Console](evidence/3-aws-console.jpg)

4. Load Balancer Working  
     ![Load Balancer](evidence/4-load-balancer.jpg)

5. SSH Access: Bastion Host  
     ![Bastion SSH](evidence/5-ssh-bastion.jpg)

6. SSH Access: Web Server (Private)  
     ![Web SSH](evidence/6-ssh-web.jpg)

7. Database Connection (Postgres)  
     ![DB Connection](evidence/7-ssh-db.jpg)

## Cleanup
To remove all resources and avoid AWS charges:
```bash
terraform destroy -auto-approve
```