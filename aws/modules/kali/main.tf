resource "aws_instance" "kali" {

  connection {
    user = "ec2-user"
    host = self.public_ip
  }

  instance_type          = "t2.medium"
  ami                    = "ami-0a967289406d51ad4"
  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Owner       = "secdevops"
    Terraform   = "true"
    Environment = "dev"
  }
}


