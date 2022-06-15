# create security group to access the ecs cluster (traffic to ecs cluster should only come from the ALB)
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-from-alb-group"
  description = "control access to the ecs cluster"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allow_ports_ecs
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.alb_sg.id]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "postgres-public-group"
  description = "access to public rds instances"
  vpc_id      = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.allow_ports_rds
    content {
      protocol        = "tcp"
      from_port       = ingress.value
      to_port         = ingress.value
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.alb_sg.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#====================================
#===================================
#=====================================
# create security group
resource "aws_security_group" "public-sg" {
  name        = "public-group-default"
  description = "access to public instances"
  vpc_id      = aws_vpc.main.id
}

# create security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-group"
  description = "control access to the application load balancer"
  vpc_id      = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.allow_ports_alb
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  # ingress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"
  #   cidr_blocks = [
  #   "0.0.0.0/0"]
  # }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}
