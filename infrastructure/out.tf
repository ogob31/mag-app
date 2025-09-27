output "vpc_id" {
  value       = aws_vpc.mag.id
  description = "New VPC ID"
}

output "public_subnet_a_az" {
  value       = aws_subnet.public_a.availability_zone
  description = "AZ for subnet A (not us-east-1e)"
}

output "runner_public_ip" {
  value       = aws_instance.runner.public_ip
  description = "Public IP of the MAG runner"
}

output "ssh_private_key_path" {
  value       = local_sensitive_file.mag_private_key.filename
  description = "Path to the generated PEM file"
  sensitive   = true
}


