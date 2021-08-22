provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "ES_subnet" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id            = aws_vpc.main.id
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"

  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.ES_subnet.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  name        = "${var.vpc}-elasticsearch-${var.domain}"
  description = "Security Group for ElasticSearch"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      aws_vpc.main.cidr_block
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      aws_vpc.main.cidr_block, "0.0.0.0/0"
    ]
  }

  ingress {
  from_port = 5000
  to_port   = 5000
  protocol  = "tcp"

  cidr_blocks = [
    aws_vpc.main.cidr_block, "0.0.0.0/0"
  ]
  }

  egress {
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain
  elasticsearch_version = "7.7"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }

  vpc_options {
    subnet_ids =  [aws_subnet.ES_subnet.id]
    security_group_ids = [aws_security_group.es.id]
  }

    ebs_options {
      ebs_enabled = true
      volume_size = 10
  }

  access_policies = <<CONFIG
{"Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Domain = "TestDomain"
  }
}

resource "aws_ecr_repository" "flask_app" {
  name                 = "flask_app"
}

resource "aws_key_pair" "ci_ssh_pair" {
  key_name = "gaby-test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAoZMbYDVeHdN3djoLE8z240l5c8g++TYehtZGhnkRNUZdYOppMSbK+8TA+n+bwFzsMVRBT4KVGi17w6fj5tCBOXDTs8nNt93QHNrZHVlGhwSBFnz8x4NoXl3KAXtOM8LQdpwn3NbNYUAbnBlBuC76DPHe49g/GTY/CXanCjZ8ZaLImDQ9EBA6KzJMyp/TicDcsk4kICdR0hr7taynhSfyTFhkNIiOqx+A5FVzp7znN14qCK4pDr3iiBkVlztkO1PUlBidTguxCEtWVIBqVXIv2t5VBBmd13Yq+cexsUCo/9ttkxN4NGUxBnYMBSyL6a8g0v+kX+c5tIt9DNDioXGKGw== rsa-key-20200312"
}

resource "aws_instance" "ci_prod_machine" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name = aws_key_pair.ci_ssh_pair.key_name
  associate_public_ip_address = true
  subnet_id     = aws_subnet.ES_subnet.id
  connection {
      type =        "ssh"
      user =        "ubuntu"
      private_key =  file("/${var.ssh_private_key}")
      host =        aws_instance.ci_prod_machine.public_ip
  }
  provisioner "remote-exec" {
      inline = [
          "sudo apt update -y",
          "sudo apt install docker.io awscli -y",
          "sudo systemctl start docker",
          "sudo systemctl enable docker",
          "touch ~/elk_host",
          "echo '${aws_elasticsearch_domain.es.endpoint}' > ~/elk_host",
      ]
  }
  tags = {
    Name = "ci-prod-machine"
  }

  vpc_security_group_ids = [
    aws_security_group.es.id,
  ]
}