# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/v2.33.0/examples/simple-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "cloudlab"
  cidr = "10.0.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.10.8.0/21"]
  public_subnets  = ["10.10.15.0/21"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }

  vpc_tags = {
    Name = module.vpc.name
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.vpc.private_subnets[0]
  map_public_ip_on_launch = true

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.vpc.public_subnets[0]
  map_public_ip_on_launch = true

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "public-rt" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public-rt.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id

}


resource "aws_security_group" "default" {
  name        = "CloudLab default"
  description = "security group to access instances over SSH and HTTP"
  vpc_id = module.vpc.vpc_id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ module.vpc.private_subnets[0] ]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ module.vpc.private_subnets[0] ]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [module.vpc.vpc_cidr_block]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = module.vpc.vpc_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
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
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    host = self.public_ip
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = lookup(var.aws_amis, var.aws_region)

  # The name of our SSH keypair we created above.
  key_name = aws_key_pair.auth.id

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = aws_subnet.private.id

  provisioner "file" {
    source      = "scripts/setup_docker.sh"
    destination = "/home/ubuntu/setup_docker.sh"
  }

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
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
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = aws_subnet.private.id
  
  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}
