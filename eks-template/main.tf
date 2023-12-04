provider "aws" {
  region = "ap-south-1"
}

module "eks" {
  #inputs for vpc--------------
  vpc-name = "terraform-test-vpc"
  cidr = "10.0.0.0/16"
  azs = ["ap-south-1a","ap-south-1b"]
  public-subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private-subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable-nat-gateway = false
  enable-vpn-gateway = false
  tags = {
    terraform = "true"
  }

  #inputs for eks-------------

  source           = "../eks"
  eks-cluster-name = "test-eks-cluster-2"
  node-group-name  = "ap-south-1-node1"
  instance-types         = ["t3.small"]
  disk-size              = 30
  capacity-type          = "ON_DEMAND"
  create-fargate-profile = "true"
  profile-name           = "my-fargate"
  fargate-namespace      = "terra-fargate"
}