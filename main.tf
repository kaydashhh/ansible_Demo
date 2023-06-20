# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-2"
  #shared_config_files      = ["/Users/austi/.aws/conf"]
  #shared_credentials_files = ["/Users/austi/.aws/credentials"]
  profile                  = "default"
}

# Create a remote backend for your terraform 
terraform {
  backend "s3" {
    bucket = "docker-tfstate"
    dynamodb_table = "app-state"
    key    = "LockID"
    region = "us-east-1"
    profile = "default"
  }
}

# Create a Vpc
resource "aws_vpc" "krommVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "krommVpc"
  }
}
# Create Subnet
resource "aws_subnet" "krommSubnet" {
  vpc_id     = aws_vpc.krommVpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone      = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "krommSubnet"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "kromm-IG" {
  vpc_id = aws_vpc.krommVpc.id

  tags = {
    Name = "kromm-IG"
  }
}
# Create Route table
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.krommVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kromm-IG.id
  }

  tags = {
    Name = "Public-RT"
  }

}

# Associate subnet with route table
resource "aws_route_table_association" "Public-Ass" {
  subnet_id      = aws_subnet.krommSubnet.id
  route_table_id = aws_route_table.Public-RT.id

}

# Create Security group
resource "aws_security_group" "Public-SG" {
  name        = "Public-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.krommVpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
  ingress {
    description      = "http from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description      = "http nginx access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "mysql access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public-SG"
  }

}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

# launch the ec2 instance and install website

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.krommSubnet.id
  vpc_security_group_ids = [aws_security_group.Public-SG.id]
  key_name               = "feb-class-key"
  user_data            = "${file("jenkins_install.sh")}"

  tags = {
    Name = "Jenkins-server"
  }
}

resource "aws_instance" "ec2_instance1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.krommSubnet.id
  vpc_security_group_ids = [aws_security_group.Public-SG.id]
  key_name               = "feb-class-key"

  tags = {
    Name = "Database-server"
  }
}

resource "aws_instance" "ec2_instance2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.krommSubnet.id
  vpc_security_group_ids = [aws_security_group.Public-SG.id]
  key_name               = "feb-class-key"

  tags = {
    Name = "Nginx-Server"
  }
}

resource "aws_instance" "ec2_instance3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.krommSubnet.id
  vpc_security_group_ids = [aws_security_group.Public-SG.id]
  key_name               = "feb-class-key"

  tags = {
    Name = "Apache-Server"
  }
}
