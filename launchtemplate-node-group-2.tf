data "template_file" "launch_template_userdata_node_group_2" {
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = local.name
    endpoint            = module.eks.cluster_endpoint
    cluster_auth_base64 = module.eks.cluster_certificate_authority_data

    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "random_id" "worker-node-group-2" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = "${var.ami_id}"
  }

  byte_length = 4
}

resource "aws_launch_template" "worker-node-group-2" {
  name_prefix            = "eks-cluster-worker-node-group-2"
  description            = "worker-node-group-2 launch-Template"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 150
      volume_type           = "gp2"
      delete_on_termination = true
      # encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [module.eks.worker_security_group_id,aws_security_group.worker-nodes.id]
  }

  image_id      = var.ami_id
  key_name      = var.ssh_access_key
 

  user_data = base64encode(
    data.template_file.launch_template_userdata_node_group_2.rendered,
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      	Name      = "${local.name}-worker-${random_id.worker-node-group-2.hex}"
      	Description   = "linode eks cluster worker nodes created by terraform"
        SHUTDOWN      = "${var.tag_shutdown}"
    	POC           = "${var.tag_poc}"
    	CUSTOMER      = "${var.tag_customer}"
    	ENV           = "${var.tag_env}"
    	PLATFORM_TYPE = "${var.tag_platform_type}"
    }
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC)
  tag_specifications {
    resource_type = "volume"

    tags = {
      CustomTag = "Volume custom tag"
    }
  }

  # Supplying custom tags to EKS instances ENI's is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "network-interface"

    tags = {
      CustomTag = "EKS example"
    }
  }

  # Tag the LT itself
  tags = {
    CustomTag = "Launch template custom tag"
  }

  lifecycle {
    create_before_destroy = true
  }
}
