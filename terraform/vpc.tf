data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}

resource "aws_subnet" "main" {
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 1)}" // 10.0.1.0/24
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "default"
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "default"
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "default"
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}

resource "aws_security_group" "allow_server_traffic_from_internet" {
  name        = "ECSAllowTrafficFromInternet"
  description = "Allow inbound traffic from internet to server port"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol = "udp"
    from_port = 27015
    to_port = 27015
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 27015
    to_port = 27015
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    ServiceType = "GameServer"
    ServiceName = "${local.service_name}"
  }
}
