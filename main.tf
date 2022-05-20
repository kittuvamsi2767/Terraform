provider "aws" {
  region = "us-east-1"
 }
resource "aws_vpc" "t_my_vpc_01" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc_01"
  }
}
resource "aws_subnet" "t_public_subnet" {
  vpc_id     = aws_vpc.t_my_vpc_01.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_internet_gateway" "t_igw" {
  vpc_id = aws_vpc.t_my_vpc_01.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "t_public_rt" {
  vpc_id = aws_vpc.t_my_vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.t_igw.id
  }

  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table_association" "t_public_rt_assoc" {
  subnet_id      = aws_subnet.t_public_subnet.id
  route_table_id = aws_route_table.t_public_rt.id
}
resource "aws_instance" "t_ec2_instance" {

    ami = "ami-0022f774911c1d690"  
    instance_type = "t2.micro" 
    key_name= "terraform_created_key"
    vpc_security_group_ids = [aws_security_group.t_sgrp.id]
    subnet_id  = aws_subnet.t_public_subnet.id
    tags = {
    Name = "terraform_created_instance"
    associate_public_ip_address = true
  }

 }

resource "aws_eip" "t_eip" {
  vpc = true
}

resource "aws_eip_association" "t_eip_assoc" {
  instance_id   = aws_instance.t_ec2_instance.id
  allocation_id = aws_eip.t_eip.id
}

resource "aws_security_group" "t_sgrp" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
 vpc_id = aws_vpc.t_my_vpc_01.id

  tags = {
    Name = "terraform_created_sg"
  }
}


resource "aws_key_pair" "terraform_created_key" {
  key_name   = "terraform_created_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdpel4bbH0QOC7z3P5IH2/yF0vAe7S2hh5oLn78EQh7Ke7itXkYUxBrq1NKoeTISVGxOTW/3sXjPNl6DVbpYO5yLCi/VhsokJ5Vplv5YUpI3BdQVa8cbh6nPQjuGOHcsBugrUyXBaY2leo4TYxlngMuYWlnPjP5O0yhgazCigyeDBkHkfxJvkOveKignQyBogUuQVbbeykqkGjNIqafycXWZrFo5JGK4g+PhxdcX6R41qz8VleikGDRWTRgepZpEM4JpgirIqnVOMdBzBzDWMs/yL9Zpmp6floOb8HkAdIeZZVEK2vo0SAZzCznKIl3p8VMWspO+BsSwmHakGnIRip ec2-user@ip-172-31-9-205.us-east-2.compute.internal"
}

output "t_output_instance-private-ip" {
  value = aws_instance.t_ec2_instance.private_ip
}
