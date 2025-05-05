#Add AWS Roles for Kubernetes

resource "aws_iam_role" "kube_control_plane" {
  name = "kubernetes-${var.aws_cluster_name}-master"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

resource "aws_iam_role" "kube-worker" {
  name = "kubernetes-${var.aws_cluster_name}-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

#Add AWS Policies for Kubernetes

resource "aws_iam_role_policy" "kube_control_plane" {
  name = "kubernetes-${var.aws_cluster_name}-master"
  role = aws_iam_role.kube_control_plane.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["route53:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kube-worker" {
  name = "kubernetes-${var.aws_cluster_name}-node"
  role = aws_iam_role.kube-worker.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": [
            "arn:aws:s3:::kubernetes-*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": "ec2:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:AttachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:DetachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": ["route53:*"],
          "Resource": ["*"]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
          ],
          "Resource": "*"
        }
      ]
}
EOF
}

# CSI Policy
variable "csi_policy" {
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:ModifyVolume"
      ],
      "Resource": "arn:aws:ec2:*:*:volume/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:instance/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kube_control_plane_csi_user" {
  name   = "kubernetes-${var.aws_cluster_name}-control-csi-user"
  role   = aws_iam_role.kube_control_plane.id
  policy = var.csi_policy
}

resource "aws_iam_role_policy" "kube-worker_csi_user" {
  name   = "kubernetes-${var.aws_cluster_name}-node-csi-user"
  role   = aws_iam_role.kube-worker.id
  policy = var.csi_policy
}

#Create AWS Instance Profiles
resource "aws_iam_instance_profile" "kube_control_plane" {
  name = "kube_${var.aws_cluster_name}_master_profile"
  role = aws_iam_role.kube_control_plane.name
}

resource "aws_iam_instance_profile" "kube-worker" {
  name = "kube_${var.aws_cluster_name}_node_profile"
  role = aws_iam_role.kube-worker.name
}
