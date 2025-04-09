terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "nihal" # provide the name of your aws profile
  assume_role {
    role_arn = "arn:aws:iam::871270496425:role/AnsibleSlaveConfigurationTerraformRole" # provide the role to be used
  }
}