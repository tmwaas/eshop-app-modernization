# Infrastructure as Code for AWS EKS (Native Version)
provider "aws" {
  region = var.aws_region
}

# 1. VPC & Subnets Network Dasar
resource "aws_vpc" "modernization_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "modernization-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.modernization_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags              = { "kubernetes.io/role/elb" = "1" }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.modernization_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags              = { "kubernetes.io/role/elb" = "1" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.modernization_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.modernization_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. IAM Roles for EKS Cluster & Node Group
resource "aws_iam_role" "eks_cluster_role" {
  name = "eshop-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_nodes_role" {
  name = "eshop-eks-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

# 3. Core EKS Cluster Service
resource "aws_eks_cluster" "eks" {
  name     = "eshop-modernization-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30"

  vpc_config {
    subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# 4. Linux Worker Nodes Group
resource "aws_eks_node_group" "linux_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "linux-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registry_policy,
  ]
}

# 5. AWS ECR Registry for Docker Image Linux Application
resource "aws_ecr_repository" "eshop_app" {
  name                 = "eshop-linux-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
