variable "aws_region" {
  default     = "eu-west-2"
  description = "aws region where our resources going to create choose"
  #replace the region as suits for your requirement
}

variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}

variable "ecs_task_execution_role" {
  default     = "myECcsTaskExecutionRole"
  description = "ECS task execution role name"
}

# variable "app_image" {
#   default     = "210734875628.dkr.ecr.eu-west-2.amazonaws.com/ecs-practical-app:latest"
#   description = "docker image to run in this ECS cluster"
# }

variable "app_port" {
  default     = 80
  description = "portexposed on the docker image"
}

variable "app_count" {
  default     = "2" #choose 2 bcz i have choosen 2 AZ
  description = "numer of docker containers to run"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  default     = "512"
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  default     = "3072"
  description = "Fargate instance memory to provision (in MiB) not MB"
}

variable "app_name" {
  description = "App name"
  default     = "ecsfargate-app"
}

variable "app_environment" {
  description = "App environment"
  default     = "Tes"
}