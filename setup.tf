provider "aws" {
  region     = "us-east-2"
  access_key = local.auth.access_key
  secret_key = local.auth.secret_key
}

terraform {
  backend "s3" {
    bucket = "wp-assign-state-bckt"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

locals {
  creds = yamldecode(data.aws_kms_secrets.creds.plaintext["creds"])
}

resource "aws_kms_key" "wp-kms-key" {
  description = "KMS key 1"

  tags = {
    Name = "wp-kms-key"
  }
}

data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file("~/projects/test/my-key-pair.pub")
}

data "aws_kms_secrets" "creds" {
  secret {
    name    = "creds"
    payload = file("${path.module}/creds/creds.yml.encrypted")
  }
}