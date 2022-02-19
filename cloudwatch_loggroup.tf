###########################################################
# AWS Cloudwatch
# Set up CloudWatch group and log stream and retain logs for 30 days
###########################################################
resource "aws_cloudwatch_log_group" "ecsfargateapp_log_group" {
  name              = "/fargate/service/ecsfargateapp"
  retention_in_days = 30

  tags = {
    Name        = "${var.app_name}-clwg"
    Environment = var.app_environment
  }
}

resource "aws_cloudwatch_log_stream" "ecsfargateapp_log_stream" {
  name           = "test-log-stream"
  log_group_name = aws_cloudwatch_log_group.ecsfargateapp_log_group.name
}