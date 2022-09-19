variable "AWS_REGION" {
    default = "us-west-2"
}

variable "vpc_id" {
  type = string
  default = "vpc-08581d72739859966"
}

variable "tools_vpc_id" {
  default = "vpc-0e1a336f69d005c05"
}

variable "platform_vpc_id" {
  default = "vpc-00f9549591f19d495"
}

variable "ami_id" {
 default="ami-0f27ec4aff2f36c44"
}

variable "ssh_access_key" {
 default = "dev-eks"
}

variable "route_table_id" {
 default = "rtb-05dfefb841305ecb7"
}

variable "node_group1_prefix" {
  default = "workers-APP1-"
}

variable "node_group2_prefix" {
  default = "workers-APP2-"
}


variable "cluster_name" {
  default = "linode-eks-dev"
}

variable "cluster_version" {
 default = "1.20"
}

variable "private_subnet_1_cidr" {
 default = "172.16.2.0/24"
}

variable "private_subnet_2_cidr" {
 default = "172.16.3.0/24"
}

variable "private_subnet_3_cidr" {
 default = "172.16.4.0/24"
}

variable "public_subnet_1_cidr" {
 default = "172.16.5.0/24"
}

variable "public_subnet_2_cidr" {
 default = "172.16.6.0/24"
}

variable "public_subnet_3_cidr" {
 default = "172.16.7.0/24"
}

#Tags

variable "tag_shutdown" {
 default = "Never"
}

variable "tag_poc" {
 default = "ailabs-dev@ushur.me"
}

variable "tag_customer" {
 default = "Internal"
}

variable "tag_env" {
 default = "DEV"
}

variable "tag_platform_type" {
 default = "LINODE"
}

variable "namespace" {
 default = "ushurli"
}

variable "service_account_name" {
 default = "ushurlinodesa"
}

variable "UshurApplicationsAccess_arn" {
 default = "arn:aws:iam::920349478710:policy/UshurApplicationsAccess"
}






