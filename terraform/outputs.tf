output "cluster_name" { 
    value = aws_eks_cluster.eks.name 
}
output "ecr_repository_url" { 
    value = aws_ecr_repository.eshop_app.repository_url 
}
