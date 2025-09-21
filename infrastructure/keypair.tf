# Generate a fresh RSA SSH key
resource "tls_private_key" "mag_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS EC2 key pair from the public key
resource "aws_key_pair" "mag_key" {
  key_name   = "mag-runner-key"
  public_key = tls_private_key.mag_ssh.public_key_openssh
}

# Save the private key to a local PEM file (DO NOT COMMIT)
resource "local_sensitive_file" "mag_private_key" {
  filename        = "${path.module}/mag-runner-key.pem"
  content         = tls_private_key.mag_ssh.private_key_pem
  file_permission = "0600"
}
