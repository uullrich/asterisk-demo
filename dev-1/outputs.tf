output "asterisk_instance_id" {
  description = "ID of the Astersik instance"
  value       = aws_instance.asterisk.id
}

output "asterisk_instance_ip" {
  description = "Public IP address of the Astersik instance"
  value       = aws_instance.asterisk.public_ip
}
