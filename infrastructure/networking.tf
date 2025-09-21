# Use the AWS default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets that belong to the default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick the first subnet (any default subnet works for a demo)
locals {
  subnet_id = data.aws_subnets.default_vpc_subnets.ids[0]
}
