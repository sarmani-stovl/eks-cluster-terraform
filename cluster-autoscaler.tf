data "aws_eks_cluster" "target2" {
  name = var.cluster_name

  depends_on = [
        module.eks.kubeconfig
   ]
}





#locals {
# cluster_identity_oidc_issuer = data.aws_eks_cluster.target2.identity[0].oidc[0].issuer
# cluster_identity_oidc_issuer_arn = join ("/", [join(":", [split(":",data.aws_eks_cluster.target2.role_arn)[0],split(":",data.aws_eks_cluster.target2.role_arn)[1], split(":",data.aws_eks_cluster.target2.role_arn)[2],split(":",data.aws_eks_cluster.target2.role_arn)[4],"oidc-provider"]),split("//",data.aws_eks_cluster.target2.identity[0].oidc[0].issuer)[1]])
#}


module "cluster_autoscaler" {

  depends_on =[module.eks.kubeconfig]


  source = "./modules/cluster_autoscaler"

  enabled = true

  cluster_name                     = data.aws_eks_cluster.target2.name
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  aws_region                       = var.AWS_REGION


}
