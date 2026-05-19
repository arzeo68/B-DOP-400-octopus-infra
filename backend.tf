terraform {
  backend "s3" {
    bucket       = "alexis-terraform-state"
    key          = "epitech/octopus/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
