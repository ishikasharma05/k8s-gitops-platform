module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # ---------------------------------------------------------
  # EKS API endpoint
  # ---------------------------------------------------------

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  # ---------------------------------------------------------
  # VPC
  # ---------------------------------------------------------

  vpc_id = module.vpc.vpc_id

  # EKS control-plane ENIs
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS resources
  subnet_ids = module.vpc.public_subnets

  # ---------------------------------------------------------
  # Self-managed EC2 worker nodes
  # ---------------------------------------------------------

  self_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-workers"

      # Worker nodes in public subnets
      subnet_ids = module.vpc.public_subnets

      # EC2 instance configuration
      instance_type = "t3.medium"

      min_size     = 2
      max_size     = 3
      desired_size = 2

      disk_size = 20

      # Existing EC2 key pair
      key_name = var.worker_key_name

      # Explicit IAM role name to avoid AWS name_prefix length error
      iam_role_name = "${var.cluster_name}-worker-role"

      # EKS optimized Amazon Linux 2023
      ami_type           = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.kubernetes_version

      # Allow the EKS bootstrap/user-data configuration
      # required for the worker nodes to join the cluster
      enable_bootstrap_user_data = true

      # Worker node tags
      tags = {
        Name    = "${var.cluster_name}-worker"
        Project = "k8s-gitops-platform"
        Role    = "kubernetes-worker"
      }
    }
  }

  # ---------------------------------------------------------
  # EKS cluster tags
  # ---------------------------------------------------------

  tags = {
    Project   = "k8s-gitops-platform"
    ManagedBy = "Terraform"
  }
}