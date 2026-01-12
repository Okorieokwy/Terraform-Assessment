output "web_1_private_ip" {
  value = aws_instance.web_1.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}
