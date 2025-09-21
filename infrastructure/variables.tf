variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ingress_cidr_ssh" {
  description = "CIDR allowed to SSH (narrow to your IP!)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_cidr_web" {
  description = "CIDR allowed to reach the app port (5000)"
  type        = string
  default     = "0.0.0.0/0"
}
