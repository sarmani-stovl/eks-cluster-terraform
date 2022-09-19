locals {
   # Your AWS EKS Cluster ID goes here.
  k8s_cluster_name = var.cluster_name
}


data "aws_eks_cluster" "target" {
  name = local.k8s_cluster_name

  depends_on = [
        module.eks.kubeconfig
   ]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name

  depends_on = [
        module.eks.kubeconfig
   ]

}


provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  #load_config_file       = false
}

module "alb_ingress_controller" {

  depends_on = [    module.eks.kubeconfig  ]

  source  = "./modules/alb-ingress-controller/"

  providers = {
    kubernetes = kubernetes.eks
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.AWS_REGION
  k8s_cluster_name = data.aws_eks_cluster.target.name


}
