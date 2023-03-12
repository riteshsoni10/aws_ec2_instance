#!/bin/bash

##################################################################################
#                           HELP
##################################################################################

function usage() {
    cat <<HELP_USAGE
Desciption: Automation script to launch AWS EC2 instace with EBS Volume

Syntax: /bin/bash -v <EBS_VOLUME_SIZE> -a <AWS_ACCESS_KEY> -s <AWS_SECRET_KEY> 
    --access_key            REQUIRED: AWS ACCESS KEY
    --secret_key            REQUIRED: AWS SECRET KEY
    --vpc_id                REQUIRED: VPC ID
    --ebs_volume_size       OPTIONAL: EBS VOLUME SIZE
    --create_security_group OPTIONAL: BOOL true/false ; DEFAULT: true
    --security_group_id     OPTIONAL: Existing Security Group Id 
Output:
    Launches AWS EC2 instance with EBS

NOTE: Script is only tested on Ubuntu Operating System
HELP_USAGE
}


##################################################################################
#                           DEFAULTS
##################################################################################
EBS_VOLUME_SIZE="10"




##################################################################################
#                           PROCESS INPUT VARIABLES
##################################################################################

while [ $# -gt 0 ]; do
    case "$1" in
    -h|--help) # Display help/usage
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
done

##################################################################################
#                           VALIDATE INPUT VARIABLES
##################################################################################

## Setting up defaults
EBS_VOLUME_SIZE=${EBS_VOLUME_SIZE:-"10"}
CREATE_SECURITY_GROUP=${CREATE_SECURITY_GROUP:-"true"}

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

##################################################################################
#                           Function Definitions
##################################################################################

function controller_machine_public_ip() {
    ## Get the public IP of the Controller Node Public IP
    controller_node_public_ip=$(curl ifconfig.me)
}

function create_security_group() {
    ## Create new security group
    security_group_id=`aws ec2 create-security-group --group-name allow_ssh_access --description "Allow SSH Access" \
--vpc-id $vpc_id | jq -r '.GroupId'`

}

function allow_ssh_ingress() {
    ## Allow SSH Port from Controller Machine Node
    aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr "$controller_node_public_ip/32"
}

function create_private_key(){
    ## Create Private Key and store in the current directory in Controller Node with the same name
    aws ec2 create-key-pair --key-name $PRIVATE_KEY --profile aws_terraform_user | jq -r '.KeyMaterial' > "$PRIVATE_KEY.pem"
}


## Check operating System
operating_system=$(cat /etc/os-release | grep ^NAME) 
if [[]]
## Check if aws cli is installed

## Install aws cli on machine


##################################################################################
#                          Main Function
##################################################################################

