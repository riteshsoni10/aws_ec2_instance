#!/bin/bash

##################################################################################
#                           HELP
##################################################################################

function usage() {
    cat <<HELP_USAGE
Desciption: Automation script to launch AWS EC2 instace with EBS Volume

Syntax: /bin/bash main.sh --vpc_id <VPC_ID> --subnet_id <SUBNET_ID> --ami_id <AMI_ID> --ebs_volume_size <EBS_VOLUME_SIZE> --access_key <AWS_ACCESS_KEY> --secret_key <AWS_SECRET_KEY> 
    --access_key            REQUIRED: AWS ACCESS KEY
    --secret_key            REQUIRED: AWS SECRET KEY
    --vpc_id                REQUIRED: VPC ID
    --ami_id                REQUIRED: EC2 instance AMI ID
    --subnet_id             REQUIRED: Subnet Id
    --instance_type         OPTIONAL: EC2 Instance Type
    --ebs_volume_size       OPTIONAL: EBS VOLUME SIZE
    --private_key_name      OPTIONAL: Instance Private Key Name
    --create_security_group OPTIONAL: BOOL true/false ; DEFAULT: true
    --security_group_id     OPTIONAL: Existing Security Group Id
Output:
    Launches AWS EC2 instance with EBS

NOTE: Script is only tested on Ubuntu Operating System
HELP_USAGE
}

##################################################################################
#                           PROCESS INPUT VARIABLES
##################################################################################

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help) # Display help/usage
        usage
        exit 1
        ;;

    --access_key)
        ACCESS_KEY="$2"
        ;;
    --secret_key)
        SECRET_KEY="$2"
        ;;
    --session_token)
        SESSION_TOKEN="$2"
        ;;
    --profile)
        AWS_PROFILE="$2"
        ;;

    --vpc_id)
        VPC_ID="$2"
        ;;
    --ami_id)
        AMI_ID="$2"
        ;;
    --instance_type)
        INSTANCE_TYPE="$2"
        ;;
    --subnet_id)
        SUBNET_ID="$2"
        ;;
    --create_security_group)
        CREATE_SECURITY_GROUP="$2"
        ;;
    --security_group_id)
        SECURITY_GROUP_ID="$2"
        ;;
    --private_key_name)
        PRIVATE_KEY="$2"
        ;;
    --ebs_volume_sizes)
        EBS_VOLUME_SIZE="$2"
        ;;
    *)
        echo "*********************************"
        echo "* Error: Invalid argument Passed*"
        echo "*     $2                        *"
        echo "*********************************"
        usage
        exit 1
        ;;
    esac
    shift
    shift
done

##################################################################################
#                           VALIDATE INPUT VARIABLES
##################################################################################

## Setting up defaults
EBS_VOLUME_SIZE=${EBS_VOLUME_SIZE:-"10"}
CREATE_SECURITY_GROUP=${CREATE_SECURITY_GROUP:-"true"}
INSTANCE_TYPE=${INSTANCE_TYPE:-"t2.micro"}
PRIVATE_KEY=${PRIVATE_KEY:-"test-machine"}

## Validating AWS Credentials
if [[ -z "$ACCESS_KEY" || -z "$SECRET_KEY" ]]; then
    if [[ -z "$PROFILE" ]]; then
        echo " Missing AWS Credentials"
        echo "Please pass AWS Credentials or AWS Config Profile"
    else
        export AWS_PROFILE="$AWS_PROFILE"
    fi
else
    export AWS_ACCESS_KEY_ID="$ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$SECRET_KEY"

    if [[ ! -z "$SESSION_TOKEN" ]]; then
        export AWS_SESSION_TOKEN="$SESSION_TOKEN"
    fi
fi

## Validate required parameters
if [[ -z "$VPC_ID" || -z "$AMI_ID" || -z "$SUBNET_ID" ]]; then
    echo " Missing Required Parameters"
    echo "Kindly check the parameters passed"
    exit 1
fi

##################################################################################
#                           Function Definitions
##################################################################################

function controller_machine_public_ip() {
    ## Get the public IP of the Controller Node Public IP
    controller_node_public_ip=$(curl ifconfig.me)
}

function get_subnet_availability_zone() {
    ## Get Availability zone of the subnet
    availability_zone=$(aws ec2 describe-subnets --subnet-ids $SUBNET_ID | jq -r .Subnets[0].AvailabilityZone)
}

function check_instance_running_state() {
    instance_id="${1}"
    echo "Checking Instance Status"
    while
        INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name')
        test "$INSTANCE_STATE" != "running"
    do
        sleep 1
        echo -n '.'
    done
    echo "Instance is in Running State"
}

function create_security_group() {
    ## Create new security group
    security_group_id=$(aws ec2 create-security-group --group-name allow_ssh_access --description "Allow SSH Access" \
        --vpc-id $VPC_ID | jq -r '.GroupId')

}

function allow_ssh_ingress() {
    controller_machine_public_ip
    ## Allow SSH Port from Controller Machine Node
    aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr "$controller_node_public_ip/32"
}

function create_private_key() {
    ## Create Private Key and store in the current directory in Controller Node with the same name
    aws ec2 create-key-pair --key-name $PRIVATE_KEY | jq -r '.KeyMaterial' >"$PRIVATE_KEY.pem"
}

function create_ec2_instance() {
    ## Create EC2 instance
    ec2_instance_id=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $PRIVATE_KEY \
        --security-group-ids $security_group_id \
        --subnet-id $SUBNET_ID \
        --tag-specifications 'ResourceType=instance,Tags=[{Key="Name",Value="TEST-MACHINE"}]' | jq -r .Instances[0].InstanceId)
}

function create_ebs_volume() {
    ## Fetch Availability Zone of the Instance
    get_subnet_availability_zone

    ## Create EBS Volume
    ebs_volume_id=$(aws ec2 create-volume \
        --availability-zone $availability_zone \
        --size 1 \
        --volume-type gp2 \
        --tag-specifications 'ResourceType=volume,Tags=[{Key="Name",Value="TEST-MACHINE"}]' | jq -r .VolumeId)

    ## Attach EBS Volume to the Instance
    aws ec2 attach-volume \
        --device /dev/sdb \
        --instance-id $ec2_instance_id \
        --volume-id $ebs_volume_id
}

##################################################################################
#                          Main Logic
##################################################################################
if [[ $CREATE_SECURITY_GROUP ]]; then
    create_security_group
else
    if [[ ! -z "$SECURITY_GROUP_ID" ]]; then
        security_group_id=$SECURITY_GROUP_ID
        else:
        echo "Parameter Initialisation Error!!"
        echo "Please provide SECURITY_GROUP_ID parameter"
        exit 1
    fi
    allow_ssh_ingress
fi

create_private_key
create_ec2_instance
check_instance_running_state $ec2_instance_id
create_ebs_volume
