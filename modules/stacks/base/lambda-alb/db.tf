resource "aws_db_subnet_group" "esports" {
  name       = "esports"
  subnet_ids = [var.private_subnets]
  tags = {
    Name = "esports"
  }
}

resource "aws_db_parameter_group" "esports" {
  name   = "rds-pg"
  family = "postgres13"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  # parameter {
  #   name  = "log_connections"
  #   value = "1"
  # }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

##################
# Security Group #
##################



resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = ""
  vpc_id      = var.vpc_id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # tags {
  #   Name = "terraform-example-rds-security-group"
  # }
}

 resource "aws_db_instance" "esports" {
  identifier             = "esports"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.7"
  domain_iam_role_name = "tf-admin-account"
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.esports.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.esports.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

output "db_connection" {
  value = aws_db_instance.esports.address
}

output "db_endpoint" {
  value = aws_db_instance.esports.endpoint
}