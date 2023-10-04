data "aws_ami" "amzn-linux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*"]   #ubuntu22-lamp
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}










resource "aws_instance" "primusb-server" {
  ami                         = data.aws_ami.amzn-linux2.id       #"ami-0cb990b1bf4c61b7a"
  instance_type               = var.instanceType #"t2.micro"
  key_name                    = var.keypair      #"terraformkey-b"
  subnet_id                   = aws_subnet.primusb-subnet.id
  vpc_security_group_ids      = [aws_security_group.primusb-sg.id]
  user_data                   = file("shellscript.sh")
  user_data_replace_on_change = true


  tags = {
    Name = "primusb-server"
  }
}



resource "aws_vpc" "primusb-vpc" {
  cidr_block       = var.vpc-cidr #"10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primusb-vpc"
  }
}




resource "aws_subnet" "primusb-subnet" {
  vpc_id            = aws_vpc.primusb-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.avZone #"eu-west-3a"

  map_public_ip_on_launch = true

  tags = {
    Name = "primusb-sbn"
  }
}




resource "aws_internet_gateway" "primusb-gw" {
  vpc_id = aws_vpc.primusb-vpc.id

  tags = {
    Name = "primusb-igw"
  }
}




resource "aws_route_table" "primusb-pub-rt" {
  vpc_id = aws_vpc.primusb-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primusb-gw.id
  }

  tags = {
    Name = "primusb-pub-rt"
  }
}




resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.primusb-subnet.id
  route_table_id = aws_route_table.primusb-pub-rt.id
}




resource "aws_security_group" "primusb-sg" {
  name        = "primusb-sg"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.primusb-vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "primusb-sg"
  }
}
