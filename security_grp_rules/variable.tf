variable "security_group_rules" {
  description = " pass security rules to configure security group"
  type        = map(string)
  default = {
    # type = from_port,to_port,protocol,cidr_blocks 
     1 = "ingress,443,443,tcp,10.0.0.0/8"
     2 = "egress,443,443,tcp,0.0.0.0/0"
  }

}

variable "security_group_id" {
  description = " pass the security_group_id "
  type = string
}