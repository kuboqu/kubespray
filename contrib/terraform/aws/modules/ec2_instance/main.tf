resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.security_group_ids

  tags = merge(
    {
      "Name"        = var.instance_name
      "Environment" = var.environment
      "Role"        = var.role
    },
    var.extra_tags
  )
}
