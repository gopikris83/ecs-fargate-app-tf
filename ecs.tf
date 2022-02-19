###########################################################
# AWS Ecs Fargate cluster
###########################################################
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecsfargateapp-cluster"

  tags = {
    Name        = "${var.app_name}-ecs-cluster"
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "ecs-def" {
  family                   = "ecafargateapp-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = <<DEFINITION
    [
      {
        "name" : "${var.app_name}",
        "image" : "210734875628.dkr.ecr.eu-west-2.amazonaws.com/ecs-practical-app:latest",
        "essential" : true,
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "/fargate/service/ecsfargateapp",
            "awslogs-region" : "${var.aws_region}",
            "awslogs-stream-prefix" : "ecs"
          }
        },
        "portMappings" : [
          {
            "containerPort" : 5000,
            "hostPort" : 5000
          }
        ],
        "cpu" : ${var.fargate_cpu},
        "memory" : ${var.fargate_memory},
        "networkMode" : "awsvpc"
      }
  ]
  DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private_subnet.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-tgp.arn
    container_name   = var.app_name
    container_port   = 5000
  }

  depends_on = [aws_alb_listener.alb-listener, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}