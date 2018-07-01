# This is the role that gets attached to the CodeBuild so it can use AWS
# services in our behalf
resource "aws_iam_role" "codebuild" {
  name = "CodeBuildRoleFor${local.service_name}"
  description = "Role attached to CodeBuild for Insurgency Server access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# This is a policy that allow CodeBuild to pull and push images to AWS ECR
# https://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html
resource "aws_iam_policy" "ecr_write" {
  name        = "AmazonEC2ContainerRegistryWriteAccess"
  description = "Policy to enable access to push & pull images to ECR"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "enable_ecr_write_to_codebuild" {
  role = "${aws_iam_role.codebuild.id}"
  policy_arn = "${aws_iam_policy.ecr_write.arn}"
}

# This Policies are required in order to make CodeBuild service role work
# https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up.html#setting-up-service-role
resource "aws_iam_policy" "logs_write" {
  name        = "CloudWatchLogsWriteAccessFor${local.service_name}"
  description = "Policy to enable log creation"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "enable_logs_to_codebuild" {
  role = "${aws_iam_role.codebuild.id}"
  policy_arn = "${aws_iam_policy.logs_write.arn}"
}
