resource "aws_ecs_cluster" "foo" {
  name               = substr("${var.app_name}-${var.region}-${var.environment}-ecsCluster", 0,32 )
  capacity_providers = [aws_ecs_capacity_provider.test.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.test.name
    weight            = 1
  }
}

resource "aws_ecs_capacity_provider" "test" {
  name               = substr("${var.app_name}-${var.region}-${var.environment}-capProvider", 0,32 )

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



locals {
  cluster_name = substr("${var.app_name}-${var.region}-${var.environment}-ecsCluster", 0,32 )
  user_data = <<EOF
 #! /bin/bash
 echo "ECS_CLUSTER=${local.cluster_name}" >> /etc/ecs/ecs.config
EOF
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = substr("${var.app_name}-${var.region}-${var.environment}-launchConfig", 0,32 )
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.test_profile.arn
  security_groups             = [var.launch-config-security-group]
  key_name                    = "kia-windows-us-east-1"
  associate_public_ip_address = true
  user_data                   = base64encode(local.user_data)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name             = substr("${var.app_name}-${var.region}-${var.environment}-logGroup", 0,32 )
}

resource "aws_ecs_service" "example" {
  name            = substr("${var.app_name}-${var.region}-${var.environment}-ecsService", 0,32 )
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


resource "aws_iam_instance_profile" "test_profile" {
  name               = substr("${var.app_name}2-${var.region}-${var.environment}-instanceProfile", 0,32 )
  role               = aws_iam_role.ec2-role.name
}

resource "aws_ecs_task_definition" "service" {
  family             = "service"
  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  network_mode       = "awsvpc"
//  snapshot_id       = var.volume ? local.a_specific_snapshot_id : null
//  volume {
////    count = var.deploy_volume == true ? 1 : 0
//    name = var.attach_efs_volume ? var.volume_name : null
//
//    efs_volume_configuration {
//      file_system_id = var.attach_efs_volume == true ? var.file_system_id : null
//      root_directory = var.attach_efs_volume == true  ? var.root_directory : null
//      authorization_config {
//        access_point_id = var.attach_efs_volume == true ? var.efs_access_point : null
//        iam = var.attach_efs_volume == true ? "ENABLED" :null
//      }
//    }
//  }
  dynamic "volume" {
    for_each = var.volumes == [] ? null : var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration
        content {
          file_system_id = efs_volume_configuration.value.file_system_id
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config
            content {
              access_point_id = authorization_config.value.access_point_id
              iam = authorization_config.value.iam
            }
          }
        }
      }
    }
  }


// CLOSEST I THINK
//  dynamic "volume" {
//    for_each = var.volume
//    content {
//      name = volume.value["volume_name"]
//      host_path = volume.value["host_path"]
//      efs_volume_configuration {
//        file_system_id = volume.value["file_system_id"]
//        authorization_config {
//          access_point_id = volume.value["access_point_id"]
//          iam = volume.value["iam"]
//        }
//      }
//    }
//  }

//            dynamic "volume" {
//    for_each = var.volumes
//    content {
//      name = lookup(var.volumes, var.volumes.value["name"], null)
//      host_path = lookup(var.volumes, var.volumes.value["host_path"], null)
//     efs_volume_configuration {
//            file_system_id = lookup(var.volumes,  var.volumes.value["file_system_id"], null)
//        authorization_config {
//            access_point_id = lookup(var.volumes, var.volumes.value["access_point_id"], null)
//            iam = "ENABLED"
//        }
//      }
//    }
//  }

  container_definitions = <<-EOF
[
  {
    "name": "${var.container_name}",
    "image": "${var.container_image}",
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
        "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}"
      }
    }
  }
]
EOF
}

# IAM ROLES AND POLICY FOR ECS SERVICE

resource "aws_iam_role" "task_role" {
  name               = substr("${var.app_name}2-${var.region}-${var.environment}-taskrole", 0,32 )

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
  name               = substr("${var.app_name}2-${var.region}-${var.environment}-taskExRole", 0,32 )

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
  name = substr("${var.app_name}2-${var.region}-${var.environment}-ec2_role", 0,32 )
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
  name = substr("${var.app_name}2-${var.region}-${var.environment}-taskPolicy", 0,32 )
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
  name       = substr("${var.app_name}-${var.region}-${var.environment}-policyAttach", 0,32 )
  roles      = [aws_iam_role.task_role.name]
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = substr("${var.app_name}2-${var.region}-${var.environment}-taskExPol", 0,32 )
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
  name       = substr("${var.app_name}-${var.region}-${var.environment}-policyAttach1", 0,32 )
  roles      = [aws_iam_role.task_execution_role.name]
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

resource "aws_iam_policy" "ec2_policy" {
  name = substr("${var.app_name}2-${var.region}-${var.environment}-ec2Policy", 0,32 )
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
  name       = substr("${var.app_name}-${var.region}-${var.environment}-iamPolicy", 0,32 )
  roles      = [aws_iam_role.ec2-role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

