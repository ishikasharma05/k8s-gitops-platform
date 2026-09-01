module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      name = "gitops-platform-nodes"

      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      disk_size = 20
    }
  }

  tags = {
    Project = "k8s-gitops-platform"
  }
}