data "aws_region" "current" {}

resource "aws_security_group" "this" {
  name        = format("%s%s", var.resource_static_name, "_ec2_sg")
  vpc_id      = var.vpc_id
  description = "Controls access to instances"

  tags = merge(
    var.tags,
    map(
      "Name", format("%s%s", var.resource_static_name, "_ec2_sg"),
    )
  )
}

resource "aws_launch_template" "this" {
  name   = format("%s-%s", var.env_name, var.resource_static_name)
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.this.id]

  user_data = base64encode(
    templatefile(var.template_file, {
      REGION               = data.aws_region.current.name
    })
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    map(
      "Name", "${var.resource_static_name}_launch_template",
    ),
  )
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.resource_static_name}_asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = "EC2"

  force_delete        = true
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      map(
        "Name", "${var.resource_static_name}_asg",
      )
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_lifecycle_hook" "this" {
  count                  = length(var.subnets)
  name                   = element(aws_autoscaling_group.this.*.name, count.index)
  autoscaling_group_name = element(aws_autoscaling_group.this.*.name, count.index)
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}
