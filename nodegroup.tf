resource "aws_eks_node_group" "eks_ec2_nodegroup" {
  for_each        = { for idx, ng in var.eks_managed_nodegroups : idx => ng }
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name_prefix}${each.value.name}"
  node_role_arn   = aws_iam_role.eks_ec2_nodegroup.arn
  subnet_ids      = each.value.subnet_ids
  instance_types  = each.value.instance_type
  capacity_type   = each.value.capacity_type != null ? each.value.capacity_type : "ON_DEMAND"
  labels          = each.value.node_labels
  tags            = { Name = "${var.name_prefix}${each.value.name}" }

  scaling_config {
    desired_size = each.value.instance_number.desired
    max_size     = each.value.instance_number.max
    min_size     = each.value.instance_number.min
  }

  dynamic "taint" {
    for_each = coalesce(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  depends_on = [aws_iam_role.eks_ec2_nodegroup]
}

resource "aws_iam_role" "eks_ec2_nodegroup" {
  name               = "${var.name_prefix}role-eks-node"
  tags               = merge({ Name = "${var.name_prefix}role-eks-node" })
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_ec2_node_policy_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_ec2_nodegroup.name
}
resource "aws_iam_role_policy_attachment" "eks_ec2_node_policy_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_ec2_nodegroup.name
}
resource "aws_iam_role_policy_attachment" "eks_ec2_node_policy_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_ec2_nodegroup.name
}
resource "aws_iam_role_policy_attachment" "eks_ec2_node_policy_AmazonSSMManagedInstancre" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_ec2_nodegroup.name
}
