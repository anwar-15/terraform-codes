module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc-name 
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private-subnets
  public_subnets  = var.public-subnets

  enable_nat_gateway = var.enable-nat-gateway
  enable_vpn_gateway = var.enable-vpn-gateway

  tags = var.tags
  map_public_ip_on_launch = true
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.eks-cluster-name
  role_arn = aws_iam_role.cluster-role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    module.vpc
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

#IAM_roles: Cluster-Role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster-role" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster-role.name
}

## Node Group Config:
resource "aws_eks_node_group" "node_group_1" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.node-group-name 
  node_role_arn   = aws_iam_role.node-group-role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = var.scaling-config["desired_size"]
    max_size     = var.scaling-config["max_size"]
    min_size     = var.scaling-config["min_size"]
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.instance-types
  disk_size      = var.disk-size
  capacity_type  = var.capacity-type

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

#IAM_ ROLE: Node_group_Role
resource "aws_iam_role" "node-group-role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-group-role.name
}

#Fargate Profile
resource "aws_eks_fargate_profile" "fargate" {
  count = var.create-fargate-profile ? 1 : 0
  cluster_name           = aws_eks_cluster.eks-cluster.name 
  fargate_profile_name   = var.profile-name 
  pod_execution_role_arn = aws_iam_role.fargate-role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = var.fargate-namespace
    labels = {
      run-on-fargate = "true"
    }
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role.fargate-role
  ]
}

resource "aws_iam_role" "fargate-role" {
  name = "eks-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate-role.name
}






