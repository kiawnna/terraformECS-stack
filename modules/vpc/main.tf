# Virtual private cloud with custom cidr block.
resource "aws_vpc" "ale_vpc" {
 cidr_block = var.vpc_cidr_block

 tags = {
   Name = "${var.app_name}-vpc"
 }
}

# Internet gateway attached to VPC.
resource "aws_internet_gateway" "mainIG" {
  vpc_id = aws_vpc.ale_vpc.id

  tags = {
    Name = "mainIG"
  }
}

# Public subnet 1.
resource "aws_subnet" "public-1" {
 availability_zone = "${var.region}a"
 vpc_id = aws_vpc.ale_vpc.id
 cidr_block = var.public_subnet1_cidr_block

 tags = {
   Name = "${var.app_name}-publicsubnet-1"
 }
}

# Public subnet 2.
resource "aws_subnet" "public-2" {
  availability_zone = "${var.region}b"
  vpc_id = aws_vpc.ale_vpc.id
  cidr_block = var.public_subnet2_cidr_block

  tags = {
    Name = "${var.app_name}-publicsubnet-2"
  }
}
# Private subnet 1.
resource "aws_subnet" "private_1" {
  availability_zone = "${var.region}b"
  vpc_id = aws_vpc.ale_vpc.id
  cidr_block = var.private_subnet1_cidr_block

  tags = {
    Name = "${var.app_name}-private_1"
  }
}
# Nat gateway set up in public-subnet-1.
resource "aws_nat_gateway" "nat-gw" {
 allocation_id = aws_eip.nat.id
 subnet_id = aws_subnet.public-1.id
 tags = {
   Name = "${var.app_name}-nat-gateway"
 }
}
# Allocates an EIP to the nat gateway.
resource "aws_eip" "nat" {
 vpc = true
}


# Public route table.
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.ale_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mainIG.id
  }


  tags = {
    Name = "public_route"
  }
}
# Private route table.
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.ale_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }


  tags = {
    Name = "private_route"
  }
}

# Public route table association between public-subnet-1 and the public route table.
resource "aws_route_table_association" "rta-public-1" {
 subnet_id = aws_subnet.public-1.id
 route_table_id = aws_route_table.public_route.id
}

# Public route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rta-public-2" {
 subnet_id = aws_subnet.public-2.id
 route_table_id = aws_route_table.public_route.id
}
# Private route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rout_private_1" {
 subnet_id = aws_subnet.private_1.id
 route_table_id = aws_route_table.private_route.id
}