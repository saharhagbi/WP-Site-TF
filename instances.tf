resource "aws_instance" "wp-site" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg-publicSN-wp.id]
  subnet_id                   = aws_subnet.publicSN.id
  key_name                    = "ssh-key"
  user_data = templatefile("${path.module}/helpers/init.sh",
    {
      db-name     = "${aws_db_instance.wp-db.name}"
      db-endpoint = "${aws_db_instance.wp-db.endpoint}"
      db-username = local.creds.db-username
      db-password = local.creds.db-password
      access-key  = local.auth.access_key
      secret-key  = local.auth.secret_key
    }
  )

  tags = {
    Name = "wp-site"
  }
}

# RDS
resource "aws_db_instance" "wp-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  name                   = "wordpress"
  username               = local.creds.db-username
  password               = local.creds.db-password
  skip_final_snapshot    = true
  identifier             = "wordpress"
  vpc_security_group_ids = [aws_security_group.sg-db-wp.id]
  db_subnet_group_name   = aws_db_subnet_group.wp-subnet-db-group.id
}
