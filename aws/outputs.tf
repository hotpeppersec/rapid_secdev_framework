
output "web_public_ip" {
  description = "Public IPs assigned to the web instance"
  value       = aws_instance.web.public_ip
}

output "kali_public_ip" {
  description = "Public IPs assigned to the kali instance"
  value       = aws_instance.kali.public_ip
}
