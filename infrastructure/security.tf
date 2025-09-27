resource "aws_security_group" "mag_sg" {
  name        = "mag-sg"
  description = "Allow SSH and app port"
  vpc_id      = aws_vpc.mag.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_ssh]
  }

  ingress {
    description = "App"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_web]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mag-sg" }
}

# Jenkins UI
resource "aws_security_group_rule" "jenkins_ui" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.ingress_cidr_web]  # or replace with your IP/CIDR
  security_group_id = aws_security_group.mag_sg.id
  description       = "Allow Jenkins UI"
}
