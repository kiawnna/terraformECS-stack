
resource "aws_ecs_cluster" "foo" {
  name               = "clue"
  capacity_providers = [aws_ecs_capacity_provider.test.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.test.name
    weight            = 1
  }
}

resource "aws_ecs_capacity_provider" "test" {
  name = "test"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.auto_scaling_group_arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/aleidy-group"
}

resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.foo.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  network_configuration {
    subnets = var.subnets
    security_groups = [var.security_group]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.test.name
    weight = 1
  }
}

locals {
  user_data = <<EOF
 #! /bin/bash
 echo "ECS_CLUSTER=clue" >> /etc/ecs/ecs.config
EOF
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = "terraform-lc-example-"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.test_profile.arn
  security_groups             = [var.launch-config-security-group]
  key_name = "ale-us-east-1"
  associate_public_ip_address = true
  user_data                   = base64encode(local.user_data)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_ecs_task_definition" "service" {
  family             = "service"
  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  network_mode = "awsvpc"

  container_definitions = <<-EOF
[
  {
    "name": "${var.container_name}",
    "image": "862989290375.dkr.ecr.us-east-1.amazonaws.com/sample-express-app:latest",
    "memory": 756,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-group": "/ecs/aleidy-group"
      }
    }
  }
]
EOF
}

# IAM ROLES AND POLICY FOR ECS SERVICE

resource "aws_iam_role" "task_role" {
  name = "task_role"

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

resource "aws_iam_role" "task_execution_role" {
  name = "task_execution_role"

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

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"
  path = "/"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
              "Service": "ec2.amazonaws.com"
           },
           "Effect": "Allow",
           "Sid": ""
       }
   ]
}
EOF
}

resource "aws_iam_policy" "task_policy" {
  name = "ecs_task_policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "task-attachment"
  roles      = [aws_iam_role.task_role.name]
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "task_execution_policy"
  path        = "/"
  description = "My test policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:GetAuthorizationToken"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF

}

resource "aws_iam_policy_attachment" "task_execution_rp_attached" {
  name       = "task-attachment"
  roles      = [aws_iam_role.task_execution_role.name]
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"
  path = "/"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeTags",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:CompleteLayerUpload",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "ec2_rp_attach" {
  name       = "task-attachment"
  roles      = [aws_iam_role.ec2-role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

