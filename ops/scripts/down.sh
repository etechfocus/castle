#!/bin/bash

set -x
export AWS_PAGER=""
BASEDIR=`dirname $0`/../..

PROJECT_ID='pepper'
while getopts "p:" opt; do
    case $opt in
        p) PROJECT_ID=$OPTARG;;
        *)
        exit 1;;
    esac
done

aws cloudformation delete-stack --stack-name ${PROJECT_ID}-api-gateway-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-api-gateway-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-lambda-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-lambda-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-kinesis-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-kinesis-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-sqs-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-sqs-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-dynamo-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-dynamo-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-auth-api-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-auth-api-stack
aws cloudformation delete-stack --stack-name ${PROJECT_ID}-cognito-stack
aws cloudformation wait stack-delete-complete --stack-name ${PROJECT_ID}-cognito-stack
