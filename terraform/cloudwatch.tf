resource "aws_cloudwatch_log_group" "insurgency_server" {
  name = "${local.service_name}-Logs"

  tags {
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}
