
output "instances_public_ips" {
  description = "Public IPs assigned to the EC2 instance"
  value       = aws_instance.web.public_ip
}
