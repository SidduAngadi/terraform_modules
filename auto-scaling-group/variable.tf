variable "env_name" {
  description = "Environment Name"
  type = string
}

variable "resource_static_name" {
  description = "mention the Name of Application /business uint which is unique identifier for your resources"
  type = string
}

variable "subnets" {
  description = "list of subnets"
  type        = list(string)
  default     = []
}

variable "max_size" {
  description = "max instances"
  default     = 3
}

variable "min_size" {
  description = "max instances"
  default     = 3
}

variable "instance_type" {
  description = "Instance type for proxy nodes"
  type        = string
  default     = "t2.micro"
}

variable "asg_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A map of tags for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = " vpc id for security group"
  type = string
}

variable "ami_id" {
  description = " ami id for ec2"
  type = string
  default = "ami-063d4ab14480ac177"
}

variable "key_name" {
  description = " ami id for ec2"
  type = string
  default = "siddu"
}

variable "template_file" {
  description = " template_file for user_data"
  type = string
}