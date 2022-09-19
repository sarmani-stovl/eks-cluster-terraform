# Role

locals {
   # Your AWS EKS Cluster OIDC details goes here.
  cluster_identity_oidc_issuer_arn =  module.eks.oidc_provider_arn
  cluster_identity_oidc_issuer     =  module.eks.cluster_oidc_issuer_url
}


data "aws_iam_policy_document" "UshurLinodeInstance_EKS_policy" {
  count = 1
  depends_on =[module.eks.kubeconfig]

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "UshurLinodeInstance_EKS_role" {
  count = 1
  depends_on =[module.eks.kubeconfig]
  name               = "${var.cluster_name}-UshurLinodeInstance_EKS"
  assume_role_policy = data.aws_iam_policy_document.UshurLinodeInstance_EKS_policy[0].json
  
  inline_policy {
    name = "UshurSTSAssumeRolePolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
                      "sts:AssumeRole",
                      "sts:GetFederationToken",
                      "sts:GetSessionToken",
                      "sts:GetAccessKeyInfo",
                      "sts:GetCallerIdentity",
                      "sts:GetServiceBearerToken"
                     ]
          Effect   = "Allow"
          Resource = "*"
        },

      ]
    })
  }

}


resource "aws_iam_role_policy_attachment" "UshurLinodeInstance_EKS_attachment" {
  count = 1
  depends_on =[module.eks.kubeconfig]
  role       = aws_iam_role.UshurLinodeInstance_EKS_role[0].name
  policy_arn = var.UshurApplicationsAccess_arn
}

resource "aws_iam_role_policy_attachment" "UshurLinodeInstance_EKS_attachment_2" {
  count = 1
  depends_on =[module.eks.kubeconfig]
  role       = aws_iam_role.UshurLinodeInstance_EKS_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
