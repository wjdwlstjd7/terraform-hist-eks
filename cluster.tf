resource "aws_eks_cluster" "eks_cluster" {
  name                      = "${var.name_prefix}${var.eks_cluster_name}"
  role_arn                  = aws_iam_role.eks_cluster.arn
  version                   = var.eks_cluster_version
  enabled_cluster_log_types = [for k, v in var.eks_cluster_logging : k if v == true]


  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = var.eks_cluster_subnets
    endpoint_private_access = var.eks_cluster_endpoint.private
    endpoint_public_access  = var.eks_cluster_endpoint.public
    public_access_cidrs     = var.eks_cluster_endpoint.public_endpoint
  }


  dynamic "encryption_config" {
    for_each = var.eks_encryption.enabled ? ["secrets"] : []
    content {
      provider {
        key_arn = var.eks_encryption.kms_arn
      }
      resources = ["secrets"]
    }
  }

  depends_on = [aws_iam_role.eks_cluster]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.name_prefix}role-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        "Service" : "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}


data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_security_group" "eks_cluster" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}sg-eks-cluster"
  tags   = { Name = "${var.name_prefix}sg-eks-cluster" }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
    description = "Allow Self"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow pods to communicate with each other node"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
