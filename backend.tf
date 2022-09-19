terraform {
  backend "s3" {
    bucket="linode-eks-cluster-tf-state-backup"
    key="terraform/eks-cluster-state-cluster-linode-dev"
    region="us-west-2"
  }
}
