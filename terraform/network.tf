//-----------------vpc----------------------------------//
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpccidr
 # enable_dns_hostnames = var.enable_dns_hostnames
  #enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.myvpcname
  }
}

//-----------------------------internetgateway----------------------// 
resource "aws_internet_gateway" "igw" { 
  vpc_id =  aws_vpc.myvpc.id 

  tags = {
    Name = var.igw
  }
}

//---------------------- public subnet-----------------------------------//
resource "aws_subnet" "publicsubnet" {

  vpc_id = aws_vpc.myvpc.id 
  cidr_block       = var.subnet-cidr1[count.index]
  count = length(var.subnet-cidr1)
  availability_zone = var.availability-zone[count.index]
  
  tags = {
    Name = var.subnet1-name[count.index]
 
  }

}

// ---------------private subnet--------------------------------//
resource "aws_subnet" "privatesubnet" {

  vpc_id = aws_vpc.myvpc.id 
  cidr_block       = var.subnet-cidr2[count.index]
  count = length(var.subnet-cidr2)
  availability_zone = var.availability-zone-2[count.index]
  
  tags = {
    Name = var.subnet2-name[count.index]

  }

}

//----------------------- natgateway-------------------------------// 
resource "aws_eip" "eip" {
  vpc      = true
}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet[0].id
  tags = {
    Name = var.nat
  }
  depends_on = [aws_internet_gateway.igw]
}

//----------------- routing table--------------------------------------------//
resource "aws_route_table" "pubRoute" {

  vpc_id = aws_vpc.myvpc.id 

  route {
    cidr_block = var.pubroute-cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.pubroute
  }
}

resource "aws_route_table" "privRoute" {
  vpc_id =  aws_vpc.myvpc.id

  route {
    cidr_block = var.pubroute-cidr
    nat_gateway_id = aws_nat_gateway.natgateway.id
  }

  tags = {
    Name = var.route-private
  }
}

resource "aws_route_table_association" "pubroute-1" {  
  subnet_id = aws_subnet.publicsubnet[0].id
  route_table_id = aws_route_table.pubRoute.id
}

resource "aws_route_table_association" "pubroute-2" {  
  subnet_id = aws_subnet.publicsubnet[1].id
  route_table_id = aws_route_table.pubRoute.id
}

resource "aws_route_table_association" "privroute-1" {  
  subnet_id = aws_subnet.privatesubnet[0].id
  route_table_id = aws_route_table.privRoute.id
}

resource "aws_route_table_association" "privroute-2" {  
  subnet_id = aws_subnet.privatesubnet[1].id
  route_table_id = aws_route_table.privRoute.id
}

//-----------------------VM---------------------------//
resource "aws_instance" "ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_type
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  subnet_id                   = aws_subnet.publicsubnet[0].id
  associate_public_ip_address = "true"
  key_name                    = var.key_pair
  tags = {
    Name = var.ec2
  }
  
}
//--------------Provides an IAM instance profile.----------------------//

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.example.name
}



//-------------------- security group----------------------------//
resource "aws_security_group" "allow_tls" {
  name        = var.security-name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port        = 80 
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.pubroute-cidr]
  }
  ingress {
    from_port        = 22 
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.pubroute-cidr]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.pubroute-cidr]
  }

 
}