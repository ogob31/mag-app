variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ingress_cidr_ssh" {
  description = "CIDR allowed to SSH (restrict in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_cidr_web" {
  description = "CIDR allowed to reach the app"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

variable "key_name" {
  description = "Existing EC2 key pair name (leave empty to let TF create one)"
  type        = string
  default     = ""
}

variable "user_data_path" {
  description = "Relative path to user_data.sh"
  type        = string
  default     = "user_data.sh"
}
