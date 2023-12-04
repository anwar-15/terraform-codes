# VPC variables
variable "vpc-name" {
  description = "Name of the vpc *"
  type = string
  default = "eks-cluster-vpc"
}

variable "cidr" {
  description = "vpc cidr *"
  type = string
  default = "10.0.0.0/16"
}

variable "azs" {
  description = "List of azs *"
  type = list(string)
}

variable "private-subnets" {
  description = "List of private subnets. Minimum 2 is required*"
  type = list(string)
  default = []
}

variable "public-subnets" {
  description = "List of public subnets Minimum 2 is required*"
  type = list(string)
  default = []
}

variable "enable-nat-gateway" {
  type = bool
  default = false
}

variable "enable-vpn-gateway" {
  type = bool
  default = false
}

variable "tags" {
  description = "Tags fot the vpc *"
  type = map
  default = {}
}

#-----------------
# eks variables 
variable "eks-cluster-name" {
  description = "Name of the eks cluster *"
  type = string
  default = "my-cluster"
}

variable "node-group-name" {
  description = "Name of the Node group *"
  type = string
  default = "node1"
}

variable "scaling-config" {
  description = "Desired size, max_size, min_size *"
  type = map
  default = {
    desired_size = 1
    max_size = 1
    min_size = 1
  }
}

variable "instance-types" {
  description = "Mention the desired instance-types"
  type = list(string)
  default = ["t3.medium"]
}

variable "disk-size" {
  description = "Value of the disk-size"
  type = number
  default = 100
}

variable "capacity-type" {
  description = "EC2 instances type : ON_DEMAND | ON_SPOT"
  type = string
  default = "ON_DEMAND"
}

variable "create-fargate-profile" {
  description = "Choice to create fargate profile *"
  type = bool
  default = false
}

variable "profile-name" {
  description = "Name of the fargate-profile *"
  type = string
  default = null
}

variable "fargate-namespace" {
  description = "Fargate profile namespace *"
  type = string
  default = null
}


