module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.name}-${var.environment}"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa               = true
  cluster_enabled_log_types = ["audit", "api", "authenticator"]

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = data.terraform_remote_state.bootstrap.outputs.kms_eks_alias_arn
    resources        = ["secrets"]
  }]

  vpc_id = data.terraform_remote_state.network.outputs.dev-remediation-vpc.id
  subnet_ids = [
    data.terraform_remote_state.network.outputs.dev-private-subnet-0.id,
    data.terraform_remote_state.network.outputs.dev-private-subnet-1.id,
    data.terraform_remote_state.network.outputs.dev-private-subnet-2.id
  ]


  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t3a.large"
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
    key_name = aws_key_pair.eks.key_name

  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      bootstrap_extra_args       = "--kubelet-extra-args '--node-labels=mine/group=default'"
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 1
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t3a.medium"
            weighted_capacity = "1"
          },
          {
            instance_type     = "m5a.large"
            weighted_capacity = "2"
          },
          {
            instance_type     = "c5a.large"
            weighted_capacity = "3"
          },
        ]
      }
    }
  }

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = data.terraform_remote_state.bootstrap.outputs.devops_role_arn
      username = "devops"
      groups   = ["system:masters"]
    },
  ]

  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::438723512299:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::438723512299:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]

  aws_auth_accounts = [
    "438723512299"
  ]

  tags = module.tags_dev.tags
}