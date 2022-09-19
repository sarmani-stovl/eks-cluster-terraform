
# Get Tools VPC CIDR

data "aws_vpc" "tools_vpc" {
  id = var.tools_vpc_id
}

data "aws_vpc" "eks_vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "controlplane" {
  name_prefix = "eks-controlplane"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["${data.aws_vpc.tools_vpc.cidr_block}","${data.aws_vpc.eks_vpc.cidr_block}"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.cluster_name}-eks-controlplane-SG"
    SHUTDOWN      = "${var.tag_shutdown}"
    POC           = "${var.tag_poc}"
    CUSTOMER      = "${var.tag_customer}"
    ENV           = "${var.tag_env}"
    PLATFORM_TYPE = "${var.tag_platform_type}"

  }
}

resource "aws_security_group" "worker-nodes" {
  name_prefix = "eks-worker-nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["${data.aws_vpc.tools_vpc.cidr_block}"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.cluster_name}-eks-worker-nodes-SG"
    SHUTDOWN      = "${var.tag_shutdown}"
    POC           = "${var.tag_poc}"
    CUSTOMER      = "${var.tag_customer}"
    ENV           = "${var.tag_env}"
    PLATFORM_TYPE = "${var.tag_platform_type}"

  }
}

