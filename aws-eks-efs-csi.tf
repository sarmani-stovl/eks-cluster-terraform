data "aws_eks_cluster" "target4" {
  name = var.cluster_name

  depends_on = [
        module.eks.kubeconfig
   ]
}



module "efs_csi_driver" {
  depends_on =[module.eks.kubeconfig]
  source = "./modules/efs_csi_driver"

  cluster_name                     = data.aws_eks_cluster.target4.name
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn =  module.eks.oidc_provider_arn
}


