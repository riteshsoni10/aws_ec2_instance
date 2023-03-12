#!/bin/bash

##################################################################################
#                           HELP
##################################################################################

function usage() {
    cat <<HELP_USAGE
Desciption: Automation script to launch AWS EC2 instace with EBS Volume

Syntax: /bin/bash -v <EBS_VOLUME_SIZE> -a <AWS_ACCESS_KEY> -s <AWS_SECRET_KEY> 
    --access_key      REQUIRED: AWS ACCESS KEY
    --secret_key      REQUIRED: AWS SECRET KEY
    --vpc_id          REQUIRED: VPC ID
    --ebs_volume_size OPTIONAL: EBS VOLUME SIZE

Output:
    Launches AWS EC2 instance with EBS

NOTE: Script is only tested on Ubuntu Operating System
HELP_USAGE
}


function controller_machine_public_ip() {
    ## Get the public IP of the Controller Node Public IP
    controller_node_public_ip=$(curl ifconfig.me)
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
        exit
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


## Function for input parameters


## Check operating System
operating_system=$(cat /etc/os-release | grep ^NAME) 
if [[]]
## Check if aws cli is installed

## Install aws cli on machine

## 