#!/bin/bash

##################################################################################
#                           HELP
##################################################################################

function usage() {
    cat <<HELP_USAGE
Desciption: Automation script to launch AWS EC2 instace with EBS Volume

Syntax: /bin/bash -v <EBS_VOLUME_SIZE> -a <AWS_ACCESS_KEY> -s <AWS_SECRET_KEY> 
    -a REQUIRED: AWS ACCESS KEY
    -s REQUIRED: AWS SECRET KEY
    -n REQUIRED: VPC ID
    -v OPTIONAL: EBS VOLUME SIZE

Output:
    Launches AWS EC2 instance with EBS

NOTE: Script is only tested on Ubuntu Operating System
HELP_USAGE
}


##################################################################################
#                           DEFAULTS
##################################################################################
EBS_VOLUME_SIZE="10"


## Function for input parameters


## Check operating System
operating_system=$(cat /etc/os-release | grep ^NAME) 
if [[]]
## Check if aws cli is installed

## Install aws cli on machine

## 