variable "vpc_id" {}
variable "route_table_id" {}
variable "cluster_name" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}
variable "private_subnet_3_cidr" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "public_subnet_3_cidr" {}

data "aws_vpc" "selected"{
  id = var.vpc_id
}

data "aws_subnet_ids" "existing_subnet_ids" {
  vpc_id = var.vpc_id
}

data "aws_subnet" "existing_subnets" {
  for_each = data.aws_subnet_ids.existing_subnet_ids.ids
  id       = each.value
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  subnet_arr_len = length([for s in data.aws_subnet.existing_subnets : s.cidr_block])
  prefix_private = "${var.cluster_name}-private-subnet-"
  prefix_public  = "${var.cluster_name}-public-subnet-"
  new_len = sum([length([for s in data.aws_subnet.existing_subnets : s.cidr_block]), 1])
  new_len2 = sum([local.new_len, 1])
  new_len3 = sum([local.new_len2, 1])
}



resource "aws_subnet" "subnet-1" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len)
    cidr_block = var.private_subnet_1_cidr
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
        Name = "${local.prefix_private}-1"
	"kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "1"
 	"kubernetes.io/role/elb" = "0"
    }
}


resource "aws_subnet" "subnet-2" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len2)
    cidr_block = var.private_subnet_2_cidr
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
        Name = "${local.prefix_private}-2"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/role/elb" = "0"

    }
}

resource "aws_subnet" "subnet-3" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len3)
    cidr_block = var.private_subnet_3_cidr
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
        Name = "${local.prefix_private}-3"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/role/elb" = "0"

    }
}


# create public suubnets

resource "aws_subnet" "subnet-4" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len)
    cidr_block = var.public_subnet_1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
        Name = "${local.prefix_public}-4"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "0"
        "kubernetes.io/role/elb" = "1"

    }
}


resource "aws_subnet" "subnet-5" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len2)
    cidr_block = var.public_subnet_2_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
        Name = "${local.prefix_public}-5"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "0"
        "kubernetes.io/role/elb" = "1"

    }
}

resource "aws_subnet" "subnet-6" {
    vpc_id = data.aws_vpc.selected.id
    #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, local.new_len3)
    cidr_block = var.public_subnet_3_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
        Name = "${local.prefix_public}-6"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "0"
        "kubernetes.io/role/elb" = "1"

    }
}


resource "aws_route_table_association" "subnet-1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = var.route_table_id
}

resource "aws_route_table_association" "subnet-2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = var.route_table_id
}

resource "aws_route_table_association" "subnet-3" {
  subnet_id      = aws_subnet.subnet-3.id
  route_table_id = var.route_table_id
}




