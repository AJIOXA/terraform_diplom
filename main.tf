provider "aws" {
  region = "us-east-2"
}

# create the RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier        = "postgres"
  allocated_storage = 5
  #storage_type           = "gp2"
  multi_az               = false
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  name                   = "postgresdb"
  username               = "postgres"
  password               = "12345678"
  port                   = 5432
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
  # family = "postgres9.6"
  parameter_group_name        = "default.postgres13"
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name # id
  publicly_accessible         = true                                     # true(if required)
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = true
  storage_encrypted           = false
  skip_final_snapshot         = true
  final_snapshot_identifier   = "worker-final"

  tags = {
    Name = "flask-postgres-rds"
  }
}
#===============================================

#ECS cluster
#===============================================

resource "aws_ecs_cluster" "fp-ecs-cluster" {
  name = "flask-app"

  tags = {
    Name = "flask-app"
  }
}

data "template_file" "task_definition_template" {
  template = file("./task_definition.json.tpl")
  vars = {
    REPOSITORY_URL    = "762135247538.dkr.ecr.us-east-1.amazonaws.com/project_app:latest"
    POSTGRES_USERNAME = "postgres"
    POSTGRES_DATABASE = "postgresdb"
    POSTGRES_ENDPOINT = aws_db_instance.rds_instance.endpoint
    POSTGRES_PASSWD   = "12345678"
    FLASK_APP         = var.flask_app
    FLASK_ENV         = var.flask_env
    FLASK_APP_HOME    = var.flask_app_home
    FLASK_APP_PORT    = 5000
    #  APP_SECRET_KEY    = replace(random_string.flask-secret-key.result, "\"", "")

  }
}

# create and define the container task
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "flask-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = data.template_file.task_definition_template.rendered
}

resource "aws_ecs_service" "flask-service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.fp-ecs-cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.public_subnets.*.id
    assign_public_ip = true
  }

  load_balancer {
    container_name   = "flask-app"
    container_port   = 5000
    target_group_arn = aws_alb_target_group.target_group.id
  }

  depends_on = [
    aws_alb_listener.fp-alb-listener
  ]
}
