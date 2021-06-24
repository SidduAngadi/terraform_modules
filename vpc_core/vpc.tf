

// Creation of VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
      "Name"             = format("%s-%s-vpc", var.env_name, var.resource_static_name)
      "AWSResoureceType" = "vpc"
    },
  )
}

// Private Subnet==============================================================

resource "aws_subnet" "private" {
  for_each                = var.private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      "Name"             = format("private-%s-%s", var.env_name, var.resource_static_name)
      "AWSResoureceType" = "Subnet"
    },
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      "Name" = format( "private-%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "rt"
      
    },
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(values(aws_subnet.private).*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


// NAT Gateway Subnet==============================================================

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.public_subnets) : 0
  vpc   = true
  tags = merge(
    var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "eip"
    },
  )
}

resource "aws_nat_gateway" "ngw" {
  count         = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.private_subnets) : 0
  allocation_id = element(aws_eip.nat.*.id, var.single_nat_gateway ? 0 : count.index)
  subnet_id = element(
    values(aws_subnet.public).*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "ngw"
    },
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? length(var.private_subnets) : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = var.public_ip_allocate
  tags = merge(
    var.tags,
    {
      "Name" = format( "public-%s-%s", var.env_name, var.resource_static_name)
      "AWSResoureceType" = "Subnet"
    },
  )
}
resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "igw"
    },
  )
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = merge(
    var.tags,
    {
      "Name"             = format("public_%s_%s", var.env_name, var.resource_static_name)
      "AWSResoureceType" = "Route_Table"
    },
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(values(aws_subnet.public).*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}