output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

# Subnets
// output "private_subnet_ids_map" {
//   value = {
//     for key in aws_subnet.private:
//     key.availability_zone => key.id

//   }
// }

output "public_cidr_block" {
  value = values(aws_subnet.public).*.cidr_block
}

output "private_cidr_block" {
  value = values(aws_subnet.private).*.cidr_block
}

output "private_subnet_ids" {
  value = values(aws_subnet.private).*.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public).*.id
}
# Route tables
output "public_route_table_ids" {
  value = [aws_route_table.public.*.id]
}

output "private_route_table_ids" {
  value = [aws_route_table.private.*.id]
}

output "nat_ip_ids" {
  value = [aws_eip.nat.*.id]
}

output "nat_pub_ips" {
  value = [aws_eip.nat.*.public_ip]
}

output "natgw_ids" {
  value = [aws_nat_gateway.ngw.*.id]
}

output "igw" {
  value = [aws_internet_gateway.igw.*.id]
}

output "gateway_endpoints_ids" {
  value = {
    for key in aws_vpc_endpoint.gateway_endpoints :
    key.service_name => key.id
  }

}

output "vpce_endpoint_sg_id" {
  value = aws_security_group.interface_endpoints_sg.*.id[0]
}