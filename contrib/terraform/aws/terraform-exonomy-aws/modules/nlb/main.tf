resource "aws_lb" "main" {
  name               = "${var.environment}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnets
}
