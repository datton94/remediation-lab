## TOC
- [Result](#result)
- [Prerequisites](#prerequisites)
  - [Local tools](#local-tools)
- [Infrastructure](#infrastructure)
  - [Why Terraform](#why-terraform)
  - [Bootstrap](#bootstrap)
  - [Modules](#modules)
  - [Components](#components)
- [EKS](#eks)
  - [ALB-Ingress](#alb-ingress)
  - [ArgoCD](#argocd)

## Result
### Achievements from the current setup: 
* EKS allow port 80 and 443 for external access, traffic to port 80 will be redirected to 443 by Application LoadBalancer (AWS Load Balancer Controller)
* HTTPS termination at ALB
* Envelope encryption for EKS Kubernetes Secrets is enabled using Amazon KMS so all k8s secret is encrypted
* EKS control plane logging is enabled, we can read the log from CloudWatch Log group.
* EKS cluster is running with version 1.22, latest version from AWS
* EKS cluster has been enabled OIDC for IRSA
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
* `terraform` (https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Infrastructure

### Why Terraform? 
Terraform is a powerful and convenient tool to provision and manage the infrastructure. It supports many cloud providers and is easy to use. And I prefer to use the declarative style of Terraform.

### Bootstrap
Look at the repo, you will see the terraform/bootstrap directory. It the very first component that need to be inited, create the S3 bucket needed for storing the terraform state, create users, roles and grant the permission for them by policies so I named it `bootstrap`. 

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
Because you didn't have the S3 bucket yet to store the state. Run `terraform init` to let Terraform install the provider, after that run `terraform plan` to review what will be created then run `terraform apply -auto-approve` to let Terraform do its job. Remember, for the first running, make sure you run by root account or the account that have enough permission (don't forget to change the provider profile). 

The terraform state will be located on your local machine, now your new users and role were created, let setup the AWS access key on your local machine. You need to setup profile assuming on your local machine like this

`~/.aws/config`

```
[dattonnt94]
region = ap-southeast-1
output = json

[profile devops]
role_arn = arn:aws:iam::438723512299:role/devops-terraform-lab
source_profile = dattonnt94
```

My idea is we will have many devops members use the same Terraform repo, provision cloud resources frequently and we need to have a specific role for Terraform perform.

Let uncomment the lines I mentioned above then run `terraform init`, Terraform will ask you something like "I found new remote backend configuration, do you want to migrate state to remote backend?", say `yes` and go ahead.

### Modules
We have 2 modules in `terraform/modules` 
* `Tags` : this module is for resources tagging 
* `Network`: for creating vpc, subnet, route table, ... 
For EKS, I used the official module from Terraform (https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to save time

### Components
* network: I create 2 VPCs , one for DEV env and one for STAGING. Only DEV VPC will be used in this lab, STAGING just for example that we can create separate VPCs for each environent
* dev: it for resources belong to Dev environment, include eks, necessary roles and policies for IRSA

## EKS
### ALB-ingress
Actually, its AWS Load Balancer Controller (https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/), it helps to provision an AWS ALB ingress and we can use all its features. You can access https://2048.revoz.net , this app is running on this lab EKS.

### ArgoCD 
* Official homepage: https://argo-cd.readthedocs.io/en/stable/
ArgoCD is a powerful, lightweight, and fast CD tool for kubernetes. It helps us follow the GitOps(https://www.gitops.tech/) with kubernetes easily. It can track the changes of the k8s manifest. You can access https://dev-argocd.revoz.net to see the UI, the read-only account login information will be sent later. 

#### Alternative ArgoCD: 
- FluxCD v2
- Spinnaker
- Gitlab CD

I owned the `revoz.net` domain in my AWS account.
