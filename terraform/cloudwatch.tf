resource "aws_cloudwatch_log_group" "insurgency_server" {
  name = "InsurgencyServer-Logs"

  tags {
    ServiceType = "GameServer"
    ServiceName = "InsurgencyServer"
  }
}
