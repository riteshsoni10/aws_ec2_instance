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
  <em>Fig 1.: IAM User creation </em>
</p>

3. Click on User
4. Add User
5. Enable Access type `Programmatic Access`

<p align="center">
  <img src="/screenshots/iam_user_details.png" width="950" title="Add User">
  <br>
  <em>Fig 2.: Add new User </em>
</p>

6. Attach Policies to the account
	For now, you can click on `Attach existing policies directly` and attach `Administrator Access`

<p align="center">
  <img src="/screenshots/iam_user_policy_attach.png" width="950" title="User Policies">
  <br>
  <em>Fig 3.: IAM User policies </em>
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
  <em>Fig 4.: Configure AWS Profile </em>
</p>


### Security Groups

The SSH Inbound traffic is allowed to EC2 instance from controller node only over public internet. 

```sh
sg_id = `aws ec2 create-security-group --group-name allow_ssh_access --description "Allow SSH Access" \
--vpc-id vpc-0519f2e5c27cad7d4 --profile aws_terraform_user | jq -r '.GroupId'
```

> Parameters:
>
> group-name => Security group name
>
> vpc-id     => VPC Id of the Cloud Network defined.
>
> profile    => IAM Profile Configured on controller node

<p align="center">
  <img src="/screenshots/secuity_group_creation.png" width="950" title="Security Group">
  <br>
  <em>Fig 5.: AWS Security Group </em>
</p>

Authorizing Ingress on 22 TCP port to the instance from Controller Node

<p align="center">
  <img src="/screenshots/allow_ssh_ingress.png" width="950" title="Allow SSH Ingress">
  <br>
  <em>Fig 6.: AWS Security Group </em>
</p>

### Instance Key-Pair Generation

The EC2 instance key-pair is generated using `create-key-pair` aws cli command parameter. The SSH login Key is stored in controller node in the current working directory with name `web-key.pem`.

```sh
aws ec2 create-key-pair --key-name web-key --profile aws_terraform_user | jq -r '.KeyMaterial' > web-key.pem
```

> Parameters:
>
> key-name => Key-Pair Name
>
> jq => JsonQuery Tool for saving the private key in controller node

<p align="center">
  <img src="/screenshots/key-pair-creation.png" width="950" title="AWS Instance Key-Pair">
  <br>
  <em>Fig 7.: Configure AWS Key-Pair </em>
</p>


### EC2 Instance 

The EC2 instance is launched with the key-pair and security group generated above. For now, the RedHat Enterprise Linux 8.2 AMI is used i.e `ami-08369715d30b3f58f`. The Official Redhat Enterprise Linux AMI Ids can be found out using the aws cli as below

```sh
aws ec2 describe-images \
--owners 309956199498 \
--query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' \
--filters "Name=name,Values=RHEL-8*" --output table --profile aws_terraform_user
```

EC2 instance launch using aws CLI
```sh
aws ec2 run-instances \
--image-id ami-052c08d70def0ac62 \
--count 1 \
--instance-type t2.micro      \
--key-name web-key            \
--security-group-ids $sg_id        \
--subnet-id subnet-01f9026863ec9e23d \
--tag-specifications 'ResourceType=instance,Tags=[{Key="Name",Value="Web-Server"}]' \
--profile aws_terraform_user >/dev/null
```

> Parameters:
>
> image-id           => AMI id
>
> count              => No. of instances to launch
>
> instance-type      =>  Server Configuration of instance
>
> security-goup-ids  => Ids of Security Groups to be attached with Instance.
>
> subnet-id          => Subnet in which instance is going to be launched.
>
> tag-specifications => Tags attached with the instance

<p align="center">
  <img src="/screenshots/ec2_launch.png" width="950" title="AWS Instance">
  <br>
  <em>Fig 8.: EC2 instance </em>
</p>


### Provision EBS Volume

The additional volume of 1 GB is provisioned and attached to the EC2 instance for data persitency and application data segregation from the operating system data.

```sh
aws ec2 create-volume \
--availability-zone $instance_availability_zone \
--size 1 \
--volume-type gp2 \
--tag-specifications 'ResourceType=volume,Tags=[{Key="Name",Value="Web-Server"}]' \
--profile aws_terraform_user
```

Volume attached to the instance using the below CLI command

```sh
aws ec2 attach-volume \
--device /dev/sdb \
--instance-id $instance_id \
--volume-id $volume_id \
--profile aws_terraform_user 
```

<p align="center">
  <img src="/screenshots/volume_creation.png" width="950" title="AWS EBS volume">
  <br>
  <em>Fig 9.: EBS Volume </em>
</p>


## Screenshots

**1. Security Group**

<p align="center">
  <img src="/screenshots/security_group.png" width="950" title="AWS EC2 security group">
  <br>
  <em>Fig 10.: Security Group </em>
</p>


**2. Instance Key-Pair**

<p align="center">
  <img src="/screenshots/key-pair.png" width="950" title="AWS Key-Pair">
  <br>
  <em>Fig 11.: Instance Key-Pair </em>
</p>


**3. EC2 Instance**

<p align="center">
  <img src="/screenshots/web-instance.png" width="950" title="AWS EC2 instance">
  <br>
  <em>Fig 12.: AWS EC2 instance </em>
</p>


**4. EBS Volume**

<p align="center">
  <img src="/screenshots/volumes.png" width="950" title="EBS Volumes">
  <br>
  <em>Fig 13.: EBS Volumes </em>
</p>


