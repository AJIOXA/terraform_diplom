# # create the ALB
# resource "aws_alb" "alb" {
#   load_balancer_type = "application"
#   name               = "application-load-balancer"
#   subnets            = aws_subnet.public_subnets.*.id
#   security_groups    = [aws_security_group.alb_sg.id]
# }
#
# # point redirected traffic to the app
# resource "aws_alb_target_group" "target_group" {
#   name        = "ecs-target-group"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"
# }
#
# # direct traffic through the ALB
# resource "aws_alb_listener" "fp-alb-listener" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     target_group_arn = aws_alb_target_group.target_group.arn
#     type             = "forward"
#   }
# }
# create the ALB
resource "aws_alb" "alb" {
  load_balancer_type = "application"
  name               = "application-load-balancer"
  subnets            = aws_subnet.public_subnets.*.id
  security_groups    = [aws_security_group.alb_sg.id]
}

# point redirected traffic to the app
resource "aws_alb_target_group" "target_group" {
  name                          = "ecs-target-group"
  port                          = 5000
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.main.id
  target_type                   = "ip"
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    healthy_threshold   = 3
    interval            = 60
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = 10
    path                = "/"
    unhealthy_threshold = 3
  }
}

# direct traffic through the ALB
resource "aws_alb_listener" "fp-alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}
