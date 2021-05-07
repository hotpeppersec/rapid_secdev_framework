provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0.0"

  name        = "CloudLab"
  description = "Security group for the cloud lab"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "web" {

  connection {
    user = "ubuntu"
    host = self.public_ip
  }

  ami                         = lookup(var.aws_amis, var.region)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.auth.id
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "scripts/setup_docker.sh"
    destination = "/home/ubuntu/setup_docker.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sh /home/ubuntu/setup_docker.sh"
      #"sudo apt-get -y install nginx",
      #"sudo service nginx start",
    ]
  }
  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "kali" {

  connection {
    user = "ec2-user"
    host = self.public_ip
  }

  instance_type          = "t2.medium"
  ami                    = "ami-0a967289406d51ad4"
  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [module.security_group.this_security_group_id]
  subnet_id              = tolist(data.aws_subnet_ids.all.ids)[0]

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}