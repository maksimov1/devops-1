terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-2"
}

resource "aws_security_group" "task3_security" {

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "task3_ssh_public" {
  key_name   = "ssh key"
  public_key = file("/home/user/.ssh/id_rsa.pub")
}


resource "aws_instance" "task3" {
  ami           = "ami-0a91cd140a1fc148a"
  instance_type = "t2.micro"
  user_data = file("start.sh")

  key_name = aws_key_pair.task3_ssh_public.key_name
  vpc_security_group_ids = [
    aws_security_group.task3_security.id
  ]
}


resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "rest_api"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "rest_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "endpoint"
}

resource "aws_api_gateway_method" "Rest_Method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_db_instance" "task3_db" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  username          = "postgress_user"
  password          = "12345831"
  vpc_security_group_ids = [
    aws_security_group.task3_security.id
  ]
}

output "public_ec2_ip" {
  value       = aws_instance.task3.public_ip
  description = "IP "
}
