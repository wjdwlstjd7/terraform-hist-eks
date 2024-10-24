output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}
output "eks_cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}
output "eks_cluster_security_group_arn" {
  value = aws_security_group.eks_cluster.arn
}
output "eks_cluster_node_iam_role_arn" {
  value = aws_iam_role.eks_ec2_nodegroup.arn
}
