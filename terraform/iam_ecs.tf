data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ECSTaskExecutionRole"
  description = "Role attached to ECS Task Execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_ecs_task_execution_policy_to_role" {
  role = "${aws_iam_role.ecs_task_execution.name}"
  policy_arn = "${data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn}"
}
