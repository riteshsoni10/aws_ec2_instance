# Compute Server Provisioning using AWS CLI

The project consists the steps to provision compute instance on AWS Public Cloud using AWS CLI. The connectivity of the instance is configured from the controller node using security groups over the internet.

## Scope of the Project

1. Allow SSH Access from the controller node(using Security Group)
2. Authentication of Server(using Key-Pair)
3. Provision Compute instance(EC2 instance)
4. Provision and attach additional storage to instance(EBS)


## Pre-Requisites

**Packages**
- awscli 
- jq


### IAM User in AWS Account

1. Login using root account into AWS Console
2. Go to IAM Service

<p align="center">
  <img src="/screenshots/iam_user_creation.png" width="950" title="IAM Service">
  <br>
  <em>Fig 2.: IAM User creation </em>
</p>

3. Click on User
4. Add User
5. Enable Access type `Programmatic Access`

<p align="center">
  <img src="/screenshots/iam_user_details.png" width="950" title="Add User">
  <br>
  <em>Fig 3.: Add new User </em>
</p>

6. Attach Policies to the account
	For now, you can click on `Attach existing policies directly` and attach `Administrator Access`

<p align="center">
  <img src="/screenshots/iam_user_policy_attach.png" width="950" title="User Policies">
  <br>
  <em>Fig 4.: IAM User policies </em>
</p>

7. Copy Access and Secret Key Credentials


### Configure the AWS Profile in Controller Node

The best and secure way to configure AWS Secret and Access Key is by using aws cli on the controller node

```sh
aws configure --profile <profile_name>
```

<p align="center">
  <img src="/screenshots/aws_profile_creation.png" width="950" title="AWS Profile">
  <br>
  <em>Fig 5.: Configure AWS Profile </em>
</p>

