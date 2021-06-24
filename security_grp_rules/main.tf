resource "aws_security_group_rule" "this" {
  count             = length(var.security_group_rules) >= 1 ? length(var.security_group_rules) : 0
  description       = "TF Managed: Allow all VPC var traffic in"
  type              = element(split(",", element(values(var.security_group_rules), count.index)), 0)
  from_port         = element(split(",", element(values(var.security_group_rules), count.index)), 1)
  to_port           = element(split(",", element(values(var.security_group_rules), count.index)), 2)
  protocol          = element(split(",", element(values(var.security_group_rules), count.index)), 3)
  cidr_blocks       = [element(split(",", element(values(var.security_group_rules), count.index)), 4)]
  security_group_id = var.security_group_id
}