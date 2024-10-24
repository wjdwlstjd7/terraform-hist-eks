# hist-terraform-modules

HIST Terraform module repository

# Modules

| Modules Name      | validate | description                                       |
| ----------------- | -------- | ------------------------------------------------- |
| eks               | O        | EKS cluster installer                             |
| eks-addons        | O        | EKS addons plugin installer                       |
| eks-lb-controller | O        | EKS Loadbalancer Controller installer (with helm) |
| eks-argo          | O        | EKS Argo installer (with helm)                    |

## eks

```
module "eks" {
  source = "./eks"

  name_prefix = "shared-prd-"

  vpc_id              = "vpc-xxx"
  eks_cluster_subnets = ["subnet-xxx", "subnet-xxx"]

  eks_cluster_name = "eks-devops-cluster"
  cluster_version = "1.XX"
  
  eks_cluster_logging = {
    api               = true
    audit             = true
    authenticator     = true
    controllerManager = true
    scheduler         = true
  }

  eks_managed_nodegroups = [
    {
      name          = "eks-nodegroup-t3-ondemand"
      subnet_ids    = ["subnet-xxx", "subnet-xxx"]
      instance_type = ["t3.large"]
      instance_number = {
        desired = 1
        min     = 1
        max     = 2
      }
      capacity_type = "ON_DEMAND"
    },
    {
      name          = "eks-nodegroup-t3-spot"
      subnet_ids    = ["subnet-xxx", "subnet-xxx"]
      instance_type: = ["t3.large"]
      instance_number = {
        desired = 1
        min     = 1
        max     = 2
      }
      capacity_type = "SPOT"
    }
  ]

  eks_encryption = {
    enabled = false
    kms_arn = ""
  }
  eks_cluster_endpoint = {
    private         = true
    public          = true
    public_endpoint = ["0.0.0.0/0"]
  }
}
```
