provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "asterisk" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.environment_name} environment"
  }
}

resource "aws_subnet" "pbx_network" {
  vpc_id            = aws_vpc.asterisk.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_security_group" "allow_asterisk" {
  name   = "allow-asterisk-sg"
  vpc_id = aws_vpc.asterisk.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 5060
    to_port   = 5061
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 5060
    to_port   = 5061
    protocol  = "udp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name   = "allow-ssh-sg"
  vpc_id = aws_vpc.asterisk.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}

resource "aws_security_group" "allow_asterisk_webserver" {
  name   = "allow-asterisk-webserver-sg"
  vpc_id = aws_vpc.asterisk.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 8088
    to_port   = 8088
    protocol  = "tcp"
  }
}

resource "aws_internet_gateway" "asterisk_igw" {
  vpc_id = aws_vpc.asterisk.id
  tags = {
    Name = "${var.environment_name} Env - Internet Gateway"
  }
}

resource "aws_route_table" "pbx_network_public" {
  vpc_id = aws_vpc.asterisk.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asterisk_igw.id
  }
  tags = {
    Name = "Public Subnet Route Table."
  }
}

resource "aws_route_table_association" "pbx_network_public_association" {
  subnet_id      = aws_subnet.pbx_network.id
  route_table_id = aws_route_table.pbx_network_public.id
}
