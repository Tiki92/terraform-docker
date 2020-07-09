provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

#---- Elastic Container Registry

resource "aws_ecr_repository" "test" {
  name                 = "test"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Auth docker

resource "null_resource" "auth" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --profile ${var.aws_profile} --region eu-central-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
}

# Upload docker image

resource "null_resource" "upload_img" {
  provisioner "local-exec" {
    command = "docker build -t test . && docker tag test:latest ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/test:latest &&  docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/test:latest"
  }
}
