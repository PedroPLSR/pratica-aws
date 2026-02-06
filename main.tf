terraform{
    required_version = ">= 1.0.0"
    required_providers{
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        tls = {
            source  = "hashicorp/tls"
            version = "~> 4.0"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}


data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

}

resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_key" {
    key_name   = "terraform-aws-key"
    public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
    content         = tls_private_key.ssh_key.private_key_pem
    filename        = "${path.module}/terraform-aws-key.pem"
    file_permission = "0400"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
        name = "rede-Unifor"
    }
}

resource "aws_internet_gateway" "g_main" {
    vpc_id = aws_vpc.main.id
    tags = {
        name = "gw-rede-unifor"
    }
}

resource "aws_subnet" "public" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        name = "subnet-rede-unifor-public"
    }
}

resource "aws_route_table" "r_public" {
    vpc_id = aws_vpc.main.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.g_main.id
    }
    tags = {
        name = "rtb-rede-unifor-public"
    }
}

resource "aws_route_table_association" "a_public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.r_public.id
}

resource "aws_security_group" "webserver" {
    vpc_id      = aws_vpc.main.id
    name        = "securitygroup-webserver-aula-terraform"
    description = "Permitir a porta 80 e 22 para acesso web e ssh"
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH Access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Permitir tudo"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg-webserver-aula-terraform"
    }
}

resource "aws_instance" "ec2_webserver" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.webserver.id]
    key_name      = aws_key_pair.terraform_key.key_name
    
    tags = {
        name = "ec2-webserver-aula-terraform"
    }
}

output "ip_publica" {
    description = "Public IP of the web server"
    value       = aws_instance.ec2_webserver.public_ip
}

output "url_publica" {
    description = "Public IP of the web server"
    value       = "http://${aws_instance.ec2_webserver.public_ip}"
}

output "cmd_ssh" {
    description = "Command to connect to the web server via SSH"
    value       = "ssh ubuntu@${aws_instance.ec2_webserver.public_ip}"
}

