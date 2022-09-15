provider "aws" {}

resource "aws_instance" "drone" {
  instance_type          = "t2.medium"
  ami                    = "ami-0323c3dd2da7fb37d"
  subnet_id              = aws_subnet.drone.id
  vpc_security_group_ids = [aws_security_group.drone.id]
  key_name               = "roman"
  iam_instance_profile   = "buildbot"
  root_block_device {
    volume_size           = 20
  }
  tags                   = {
    Name = "drone"
  }
}

resource "aws_eip" "drone" {
  vpc               = true
  tags = {
    Name            = "drone"
  }
}

resource "aws_eip_association" "drone" {
  instance_id   = aws_instance.drone.id
  allocation_id = aws_eip.drone.id
}

resource "aws_vpc" "drone" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "drone"
  }
}

resource "aws_internet_gateway" "drone" {
  vpc_id = aws_vpc.drone.id
}

resource "aws_subnet" "drone" {
  vpc_id            = aws_vpc.drone.id
  cidr_block        = cidrsubnet(aws_vpc.drone.cidr_block, 8, 1)
  availability_zone = "us-east-1a"
  tags = {
    Name = "drone"
  }
}

resource "aws_security_group" "drone" {
  vpc_id      = aws_vpc.drone.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "drone"
  }
}

resource "aws_default_route_table" "drone" {
  default_route_table_id = aws_vpc.drone.default_route_table_id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.drone.id
  }
  tags = {
    Name = "drone"
  }
}

data "aws_route53_zone" "drone" {
  name         = "columnstore.mariadb.net"
  private_zone = false
}

resource "aws_route53_record" "drone" {
  zone_id = data.aws_route53_zone.drone.zone_id
  name    = "ci.${data.aws_route53_zone.drone.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.drone.public_ip]
}

resource "aws_route53_record" "autoscaler" {
  zone_id = data.aws_route53_zone.drone.zone_id
  name    = "autoscaler.${data.aws_route53_zone.drone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.drone.name]
}

resource "aws_route53_record" "autoscaler-arm" {
  zone_id = data.aws_route53_zone.drone.zone_id
  name    = "autoscaler-arm.${data.aws_route53_zone.drone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.drone.name]
}
