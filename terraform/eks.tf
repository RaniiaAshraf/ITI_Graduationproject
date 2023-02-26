//-------------eks role-----------------// 
resource "aws_iam_role" "role" {
  name = "eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role.name
}

//-----------------eks cluster ---------------------------------///
resource "aws_eks_cluster" eks"" {
  name     = "eks"
  role_arn = aws_iam_role.role.arn

  vpc_config {
    subnet_ids = [
     aws_subnet.privatesubnet[0].id,
     aws_subnet.privatesubnet[1].id,  
     aws_subnet.publicsubnet[0].id,
     aws_subnet.publicsubnet[1].id

    ]
    endpoint_private_access = true
    endpoint_public_access  = true  
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  ]
}


# kubectl create namespace jenkins
#  aws eks --region us-east-1 update-kubeconfig --name eks-cluster
#  kubectl get svc \
#  kubectl apply -f deployment.yaml -n jenkins
#  kubectl logs jenkins-7b586bdbcd-9dl9q -n jenkins