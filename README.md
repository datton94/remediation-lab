## TOC
- [Result](#result)
- [Prerequisites](#prerequisites)
  - [Local tools](#local-tools)
- [Infrastructure](#Infrastructure)
  - [Why Terraform](#why-terraform)
  - [Bootstrap]
  - [Modules]
  - [Components]
- [EKS]
  - [ALB-Ingress]
  - [ArgoCD]

## Result
### Achievements from the current setup: 
* EKS allow port 80 and 443 for external access, traffic to port 80 will be redirected to 443 by Application LoadBalancer (AWS Load Balancer Controller)
* HTTPS termination at ALB
* Envelope encryption for EKS Kubernetes Secrets is enabled using Amazon KMS so all k8s secret is encrypted
* EKS control plane logging is enabled, we can read the log from CloudWatch Log group.
* EKS cluster is running with version 1.22, latest version from AWS
* K8s manifest is monitored by ArgoCD, if there is any changes ArgoCD will show the out of date status

### Tech Stack
* `AWS`: Cloud Provider
* `Terraform`: provision infrastructure, infrastructure as code
* `ArgoCD`: GitOps CD for kubernetes
## Prerequisites

### Local tools
* `kubectl` (https://kubernetes.io/docs/tasks/tools/)
* `kustomization-4.1.*` (https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.1.3)
* `aws-iam-authenticator` used by `aws-cli` (https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.5)
* `aws-cli` (https://github.com/aws/aws-cli/tags)
* `terraform` ()

## Infrastructure

### Why Terraform? 
Terraform is a powerful and convenient tool to provision and manage the infrastructure. It supports many cloud providers and is easy to use. And I prefer to use the declarative style of Terraform.

### Bootstrap
Look at the repo, you will see the terraform/bootstrap directory. It the very first component that need to be inited, create the S3 bucket needed for storing the terraform state, create users, roles and grant the permission for them by policies. 

For the first run, you need to comment out these line on provider.tf 
```
terraform {
  backend "s3" {
    bucket         = "terraform-boostrap"
    key            = "bootstrap.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-boostrap"
    profile        = "devops"
    encrypt        = true
    kms_key_id     = "4ccd498b-ab0b-47c8-ba95-af00c14fd8ee"
  }
}
```
Because you didn't have the S3 bucket yet to store the state. Run `terraform init` to let Terraform install the provider, after that run `terraform plan` to review what will be created then run `terraform apply -auto-approve` to let Terraform do its job.

The terraform state will be located on your local machine, let uncomment the lines I mentioned above then run `terraform init`, Terraform will ask you something like "I found new remote backend configuration, do you want to migrate state to remote backend?", say yes and go ahead.