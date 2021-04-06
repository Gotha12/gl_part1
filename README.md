# Basic AWS infrastructure

Terraform configuration which creates two Ubuntu instances on AWS VPC. The load balancer distributes traffic to indicated
instances under a target group.    

## Usage

```bash
$ terraform init
$ terraform plan
$ terraform apply
```