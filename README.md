# eks-compute-autoscaling
Repo for Cluster Autoscaler vs Karpenter Blog at Kapstan

## Install awscli

```
brew install awscli
```

## Configure aws cli

https://docs.aws.amazon.com/cli/latest/reference/configure/index.html

## Install Terraform

```
brew install terraform
```

## Install Kubectl

```
brew install kubernetes-cli
```

## Install EKS Node Viewer

```
brew tap aws/tap
brew install eks-node-viewer
```

## Setup Infrastructure
The following commands assume you are in `eks-compute-autoscaling` directory

- Add the access_key and secret_key to infrastructure/terraform.auto.tfvars

```
access_key = "Your AWS account Access Key"
secret_key = "You AWS account Secret Key"
```

- Create the infrastructure
```
cd infrastructure
terraform init
terraform plan
terraform apply
```

## Add Karpenter to the EKS cluster

- Get the output from infrastructure

```
cd infrastructure
terraform output -json
```

- Add the required output vaules in karpenter/terraform.auto.tfvars

```
cluster_name                       = "autoscaler-demo"
region                             = "us-west-2"
cluster_certificate_authority_data = ""
cluster_endpoint                   = ""
karpenter_instance_profile_name    = ""
karpenter_irsa_arn                 = ""
karpenter_role_arn                 = ""
eks_managed_node_group_id          = ""
```

- Add Karpenter to the cluster

```
cd karpenter
terraform init
terraform plan
terraform apply
```

- View the provisioned nodes by default

```
eks-node-viewer --resources cpu,memory 
```

##  Nginx Pods to test Autoscaling
- Add the required vaules in karpenter/terraform.auto.tfvars

```
cluster_name                       = "autoscaler-demo"
cluster_certificate_authority_data = ""
cluster_endpoint                   = ""
```

- Deploy nginx pods to scale up the nodes

```
cd nginx
terraform init
terraform plan
terraform apply
```
- View Nodes

```
eks-node-viewer --resources cpu,memory
```

- Output (Might change based on what node Karpenter chooses to provision)


- Remove nginx pods to scale down the nodes

```
terraform destroy
```

## Remove Karpenter

```
cd karpenter
terraform destroy
```

## Adding Cluster AuotScaler

- Please make sure to remove Karpenter before adding Cluster Autoscaler in order to view the differnce between the autoscaling capabilities of both.


## Add Cluster Autoscaler to the EKS cluster

- Get the output from infrastructure

```
cd infrastructure
terraform output -json
```

- Add the required vaules in cluster-autoscaler/terraform.auto.tfvars

```
cluster_autoscaler_irsa_arn = ""
cluster_autoscaler_irsa_name = "cluster-autoscaler"
cluster_certificate_authority_data = ""
cluster_endpoint = ""
cluster_name = "autoscaler-demo"
region = "us-west-2"
```

- Deploy Cluster Autoscaler to the cluster

```
cd cluster-autoscaler
terraform init
terraform plan
terraform apply
```

- View Nodes

```
eks-node-viewer --resources cpu,memory
```

- Output

- Add Nginx Deployment to test autoscaling

## Configure Karpenter and Cluster Autoscaler According to Best Practices

- https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/
- https://aws.github.io/aws-eks-best-practices/karpenter/
