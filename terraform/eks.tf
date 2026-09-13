module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id = module.vpc.vpc_id

  control_plane_subnet_ids = module.vpc.private_subnets

  subnet_ids = module.vpc.private_subnets

  self_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-workers"

      subnet_ids = module.vpc.private_subnets

      instance_type = "t3.micro"

      min_size     = 2
      max_size     = 3
      desired_size = 2

      disk_size = 20

      key_name = var.worker_key_name

      iam_role_name = "${var.cluster_name}-worker-role"

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      ami_type           = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.kubernetes_version

      enable_bootstrap_user_data = true

      tags = {
        Name    = "${var.cluster_name}-worker"
        Project = "k8s-gitops-platform"
        Role    = "kubernetes-worker"
      }
    }
  }

  tags = {
    Project   = "k8s-gitops-platform"
    ManagedBy = "Terraform"
  }

  addons = {
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
  }
}
