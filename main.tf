provider "aws" {
    region = "${var.AWS_REGION}"
}

resource "random_id" "worker-nodes" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = "${var.ami_id}"
  }

  byte_length = 4
}

locals {
  name            = "${var.cluster_name}"
  cluster_version = "${var.cluster_version}"
  region          = "${var.AWS_REGION}"
}

#Subnet module

module "subnets" {
        source 			= "./modules/subnets"
        vpc_id 			= var.vpc_id
        route_table_id 		= var.route_table_id
	private_subnet_1_cidr	= var.private_subnet_1_cidr
	private_subnet_2_cidr   = var.private_subnet_2_cidr
	private_subnet_3_cidr   = var.private_subnet_3_cidr
	public_subnet_1_cidr	= var.public_subnet_1_cidr
	public_subnet_2_cidr    = var.public_subnet_2_cidr
	public_subnet_3_cidr    = var.public_subnet_3_cidr
        cluster_name		= var.cluster_name
        tag_shutdown		= var.tag_shutdown
	tag_poc			= var.tag_poc
	tag_customer		= var.tag_customer
	tag_env			= var.tag_env
	tag_platform_type	= var.tag_platform_type
}


################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "./modules/eks"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id  = "${var.vpc_id}"
  subnets = module.subnets.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  cluster_create_security_group = false
  cluster_security_group_id     = aws_security_group.controlplane.id
  manage_aws_auth=false
  enable_irsa = true

  node_groups = {
    node_group1 = {
      name_prefix      = "${var.node_group1_prefix}"
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
      
      disk_size       = 150
      disk_type       = "gp2"

      launch_template_id      = aws_launch_template.worker-node-group-1.id
      launch_template_version = aws_launch_template.worker-node-group-1.default_version
      instance_types=["t2.xlarge"]
      capacity_type  = "ON_DEMAND"
      
      bootstrap_env = {
        CONTAINER_RUNTIME = "containerd"
        USE_MAX_PODS      = false
      }

      additional_tags = {
        "node-ushurml-Application"=true
        Name    = "${var.node_group1_prefix}${random_id.worker-nodes.hex}"
    	Description   = "linode eks cluster node group created by terraform"
        SHUTDOWN      = "${var.tag_shutdown}"
    	POC           = "${var.tag_poc}"
    	CUSTOMER      = "${var.tag_customer}"
    	ENV           = "${var.tag_env}"
    	PLATFORM_TYPE = "${var.tag_platform_type}"

      }
    }

    node_group2 = {
      name_prefix      = "${var.node_group2_prefix}"
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      disk_size       = 150
      disk_type       = "gp2"

      launch_template_id      = aws_launch_template.worker-node-group-2.id
      launch_template_version = aws_launch_template.worker-node-group-2.default_version
      instance_types=["t2.xlarge"]
      capacity_type  = "ON_DEMAND"

      bootstrap_env = {
        CONTAINER_RUNTIME = "containerd"
        USE_MAX_PODS      = false
      }

      additional_tags = {
        "node-ushurml-Application"=true
        Name    = "${var.node_group2_prefix}${random_id.worker-nodes.hex}"
        Description   = "linode eks cluster node group created by terraform"
        SHUTDOWN      = "${var.tag_shutdown}"
    	POC           = "${var.tag_poc}"
    	CUSTOMER      = "${var.tag_customer}"
    	ENV           = "${var.tag_env}"
    	PLATFORM_TYPE = "${var.tag_platform_type}"

      }
    }
  }



  tags = {
    Name          = local.name
    Description   = "linode eks cluster created by terraform"
    SHUTDOWN      = "${var.tag_shutdown}"
    POC           = "${var.tag_poc}"
    CUSTOMER      = "${var.tag_customer}"
    ENV           = "${var.tag_env}"
    PLATFORM_TYPE = "${var.tag_platform_type}"
 
  }
}



