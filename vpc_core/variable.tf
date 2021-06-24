

variable "cidr_block" {
  description = "cidr block to create vpc"
  type = string
}

variable "env_name" {
  description = "Environment Name"
  type = string
}

variable "resource_static_name" {
  description = "mention the Name of Application /business uint which is unique identifier for your resources"
  type = string
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}

variable "private_subnets" {
  description = "list of subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "list of subnets"
  type        = map(string)
  default     = {}
}


variable "public_ip_allocate" {
  description = " weather to allocate public_ip_allocate"
  default     = true
  type = bool
}

variable "enable_nat_gateway" {
  description = " enable the nat gateway"
  default = false
}

variable "single_nat_gateway" {
  description = "true for single gateway"
  default = true
}

variable "gateway_endpoint_service_names" {
  description = " gateway_endpoint_service_names "
  default = []
}

variable "interface_endpoint_service_names" {
  description = "interface_endpoint_service_names"
  default = []
}
variable "aws_region" {
  description = " aws region"
  default = "eu-west-1"
}