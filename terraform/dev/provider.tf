provider "aws" {
  region  = "ap-southeast-1"
  profile = "devops"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    #args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    args = [
      "--profile",
      "devops",
      "--region",
      "ap-southeast-1",
      "eks",
      "get-token",
      "--cluster-name", #"eks-dev"
      module.eks.cluster_id
      ]
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-boostrap"
    key            = "dev.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-boostrap"
    profile        = "devops"
    encrypt        = true
    kms_key_id     = "4ccd498b-ab0b-47c8-ba95-af00c14fd8ee"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = "terraform-boostrap"
    key    = "bootstrap.tfstate"
    profile        = "devops"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-boostrap"
    key    = "network.tfstate"
    profile        = "devops"
    region = "ap-southeast-1"
  }
}
