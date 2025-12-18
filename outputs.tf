output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "load_balancer_dns_name" {
  description = "The DNS name of the ALB (Paste this in your browser)"
  value       = aws_lb.main.dns_name
}

output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
