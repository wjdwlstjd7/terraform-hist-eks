variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type    = string
}

variable "eks_cluster_subnets" {
  type    = list(string)
  default = []
}

variable "eks_cluster_endpoint" {
  type = object({
    private         = bool
    public          = bool
    public_endpoint = set(string)
  })
  default = {
    private         = true
    public          = false
    public_endpoint = ["0.0.0.0/0"]
  }

}

variable "eks_cluster_logging" {
  type = object({
    api               = bool
    audit             = bool
    authenticator     = bool
    scheduler         = bool
    controllerManager = bool
  })
  default = {
    api               = true
    audit             = true
    authenticator     = true
    scheduler         = true
    controllerManager = true
  }
}

variable "eks_managed_nodegroups" {
  type = list(object({
    name          = string
    capacity_type = string // SPOT or ON_DEMAND 
    subnet_ids    = list(string)
    instance_type = list(string)
    instance_number = object({
      min     = number
      desired = number
      max     = number
    })
    node_labels = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
  default = []
}


variable "eks_encryption" {
  type = object({
    enabled = bool
    kms_arn = string
  })
  default = {
    enabled = true
    kms_arn = "arn:aws:kms:us-east-1:339712780682:key/5fb373c0-e47b-4c88-9626-748196ac1760"
  }
}
