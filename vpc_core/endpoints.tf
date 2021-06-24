# VPC Endpoint for S3
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "gateway_endpoints" {
  count        = length(var.gateway_endpoint_service_names)
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.${var.gateway_endpoint_service_names[count.index]}"
  tags = merge(
    var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "endpoint"
    },
  )
}

locals {
  association_list_private_subnet = flatten([
    for rt in aws_route_table.private : [
      for key in aws_vpc_endpoint.gateway_endpoints : {
        rt.id = key.id
      }
    ]
  ])

  association_list_public_subnet = flatten([
    for rt in aws_route_table.public : [
      for key in aws_vpc_endpoint.gateway_endpoints : {
        rt.id = key.id
      }
    ]
  ])

 
}


resource "aws_vpc_endpoint_route_table_association" "private_endpoint" {

  count           = length(var.gateway_endpoint_service_names) > 0 ? length(local.association_list_private_subnet) : 0
  vpc_endpoint_id = element(values(local.association_list_private_subnet[count.index]), 0)
  route_table_id  = element(keys(local.association_list_private_subnet[count.index]), 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_endpoint" {

  count           = length(var.gateway_endpoint_service_names) > 0 ? length(local.association_list_public_subnet) : 0
  vpc_endpoint_id = element(values(local.association_list_public_subnet[count.index]), 0)
  route_table_id  = element(keys(local.association_list_public_subnet[count.index]), 0)
}


# Interface Endpoints

resource "aws_vpc_endpoint" "interface_endpoints" {
  count             = length(var.interface_endpoint_service_names)
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${var.interface_endpoint_service_names[count.index]}"
  vpc_endpoint_type = "Interface"

  subnet_ids = values(aws_subnet.private).*.id

  security_group_ids = [
    aws_security_group.interface_endpoints_sg[0].id,
  ]
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "endpoint"
    },
  )
}


resource "aws_security_group" "interface_endpoints_sg" {
  count       = length(var.interface_endpoint_service_names) >= 1 ? 1 : 0
  name        = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
  vpc_id      = aws_vpc.main.id
  description = "Controls access to VPC Interface endpoints"
  tags = merge(
    var.tags,
    {
      "Name" = format( "%s-%s-0%d", var.env_name, var.resource_static_name, count.index + 1)
      "AWSResoureceType" = "endpoint"
    },
  )
}

