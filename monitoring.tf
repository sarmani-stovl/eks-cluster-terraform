
data "aws_eks_cluster" "target3" {
  name = var.cluster_name

  depends_on = [
        module.eks.kubeconfig
   ]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator2" {
  name = data.aws_eks_cluster.target3.name

  depends_on = [
        module.eks.kubeconfig
   ]

}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target3.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target3.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.aws_iam_authenticator2.token
    #load_config_file       = false
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target3.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target3.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator2.token
}


module "grafana_prometheus_monitoring" {
  
  depends_on = [     module.eks.kubeconfig   ]

  source = "./modules/grafana_prometheus_monitoring"

  enabled = true

}
