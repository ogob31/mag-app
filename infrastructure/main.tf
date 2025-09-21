# Latest Ubuntu 22.04 LTS AMI from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.mag_key.key_name
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.mag_sg.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data.sh")

  tags = { Name = "mag-runner" }
}

output "runner_public_ip" {
  value       = aws_instance.runner.public_ip
  description = "Public IP of the MAG runner"
}

output "ssh_private_key_path" {
  value       = local_sensitive_file.mag_private_key.filename
  description = "Local path to the generated PEM file"
  sensitive   = true
}
