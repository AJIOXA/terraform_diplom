variable "availability_zones" {
  description = "availability zone to create subnet"
  default = [
    "us-east-2a",
  "us-east-2b"]
}

#Network variables
#====================

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24"
  ]
}

#===========================

#Security Groups variables
#=========================

variable "allow_ports_rds" {
  description = "List of ports to open for db"
  default     = ["5432", "22"]
}

variable "allow_ports_alb" {
  description = "List of ports to open fot alb"
  default     = ["80", "5000", "5432", "22", "443"]
}

variable "allow_ports_ecs" {
  description = "List of ports to open for app"
  default     = ["5000", "22", "80", "443"]
}

#===========================

variable "flask_app_port" {
  description = "Port exposed by the flask application"
  default     = 5000
}
variable "flask_app_image" {
  description = "ECR image for flask-app"
  default     = "762135247538.dkr.ecr.us-east-1.amazonaws.com/project_app:latest"
}

variable "flask_app" {
  description = "FLASK APP variable"
  default     = "app.py"
}
variable "flask_env" {
  description = "FLASK ENV variable"
  default     = "dev"
}
variable "flask_app_home" {
  description = "APP HOME variable"
  default     = "/usr/src/app/"
}
