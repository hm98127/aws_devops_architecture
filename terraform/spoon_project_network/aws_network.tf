# VPC create
resource "aws_vpc" "spoon_project_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "spoon-project-vpc"
  }
}

# Subnet create
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.spoon_project_vpc.id
  cidr_block = "10.1.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "spoon-project-public-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.spoon_project_vpc.id
  cidr_block = "10.1.2.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "spoon-project-private-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id     = aws_vpc.spoon_project_vpc.id
  cidr_block = "10.1.3.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "spoon-project-public-subnet-c"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id     = aws_vpc.spoon_project_vpc.id
  cidr_block = "10.1.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "spoon-project-private-subnet-c"
  }
}

# Internet gateway NAT, NAT gateway create
resource "aws_internet_gateway" "spoon_project_igw" {
  vpc_id = aws_vpc.spoon_project_vpc.id

  tags = {
    Name = "spoon-project-igw"
  }
}

resource "aws_eip" "spoon_project_nat_a" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "spoon_project_nat_c" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "spoon_project_natgw_a" {
  allocation_id = aws_eip.spoon_project_nat_a.id

  subnet_id =  aws_subnet.public_subnet_a.id
  tags = {
    Name = "spoon-project-natgw-a"
  }
}

resource "aws_nat_gateway" "spoon_project_natgw_c" {
  allocation_id = aws_eip.spoon_project_nat_c.id

  subnet_id =  aws_subnet.public_subnet_c.id
  tags = {
    Name = "spoon-project-natgw-c"
  }
}

# Route_table, association create

resource "aws_route_table" "spoon_project_public_rt_a" {
  vpc_id = aws_vpc.spoon_project_vpc.id

  # Ingress Type Inner rule
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.spoon_project_igw.id
   }

  tags = {
    Name = "spoon-project-public-rt-a"
  }
}
resource "aws_route_table" "spoon_project_public_rt_c" {
  vpc_id = aws_vpc.spoon_project_vpc.id

  # Ingress Type Inner rule
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.spoon_project_igw.id
   }

  tags = {
    Name = "spoon-project-public-rt-c"
  }
}

resource "aws_route_table" "spoon_project_private_rt_a" {
  vpc_id = aws_vpc.spoon_project_vpc.id

  tags = {
    Name = "spoon-project-private-rt-a"
  }
}

resource "aws_route_table" "spoon_project_private_rt_c" {
  vpc_id = aws_vpc.spoon_project_vpc.id

  tags = {
    Name = "spoon-project-private-rt-c"
  }
}


resource "aws_route_table_association" "spoon_project_rt_association_public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.spoon_project_public_rt_a.id
}

resource "aws_route_table_association" "spoon_project_rt_association_private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.spoon_project_private_rt_a.id
}

resource "aws_route_table_association" "spoon_project_rt_association_public_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.spoon_project_public_rt_c.id
}

resource "aws_route_table_association" "spoon_project_rt_association_private_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.spoon_project_private_rt_c.id
}

# Route rule create
resource "aws_route" "spoon_project_rt_rule_1" {
  route_table_id          = aws_route_table.spoon_project_public_rt_a.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.spoon_project_igw.id
}

resource "aws_route" "spoon_project_rt_rule_2" {
  route_table_id          = aws_route_table.spoon_project_public_rt_c.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.spoon_project_igw.id
}

resource "aws_route" "spoon_project_rt_rule_3" {
  route_table_id          = aws_route_table.spoon_project_private_rt_a.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.spoon_project_natgw_a.id
}

resource "aws_route" "spoon_project_rt_rule_4" {
  route_table_id          = aws_route_table.spoon_project_private_rt_c.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.spoon_project_natgw_c.id
}

# Gateway Type Endpoint ( S3 )
## S3 Endpoint
resource "aws_vpc_endpoint" "spoon_project_s3_endpoint" {
  vpc_id       = aws_vpc.spoon_project_vpc.id
  service_name = "com.amazonaws.ap-northeast-2.s3"

  tags = {
   Name = "spoon-project-s3-ap-northeast-2"
  }
}

# Add vpc endpoint to route table of private subnet
resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_routetable_a" {
  vpc_endpoint_id = aws_vpc_endpoint.spoon_project_s3_endpoint.id
  route_table_id  = aws_route_table.spoon_project_private_rt_a.id
}


