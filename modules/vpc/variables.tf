
variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}

variable "app_name" {
  description = "App name"
  default     = "ecsfargate-app"
}

variable "app_environment" {
  description = "App environment"
  default     = "Test"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "app_port" {
  default     = 80
  description = "portexposed on the docker image"
}


