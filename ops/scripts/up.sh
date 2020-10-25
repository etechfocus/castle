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

aws cloudformation create-stack --stack-name ${PROJECT_ID}-cognito-stack \
      --template-body file://${BASEDIR}/ops/stacks/cognito-stack.yml  \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-cognito-stack

aws cloudformation create-stack --stack-name ${PROJECT_ID}-auth-api-stack \
      --template-body file://${BASEDIR}/ops/stacks/auth-api-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-auth-api-stack

aws cloudformation create-stack --stack-name ${PROJECT_ID}-dynamo-stack \
      --template-body file://${BASEDIR}/ops/stacks/dynamo-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-dynamo-stack

aws cloudformation create-stack --stack-name ${PROJECT_ID}-sqs-stack \
      --template-body file://${BASEDIR}/ops/stacks/sqs-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-sqs-stack

aws cloudformation create-stack --stack-name ${PROJECT_ID}-kinesis-stack \
      --template-body file://${BASEDIR}/ops/stacks/kinesis-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-kinesis-stack

# application specific
aws cloudformation create-stack --stack-name ${PROJECT_ID}-lambda-stack \
      --template-body file://${BASEDIR}/ops/stacks/lambda-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-lambda-stack

aws cloudformation create-stack --stack-name ${PROJECT_ID}-api-gateway-stack \
      --template-body file://${BASEDIR}/ops/stacks/api-gateway-stack.yml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=ProjectId,ParameterValue=${PROJECT_ID}
aws cloudformation wait stack-create-complete --stack-name ${PROJECT_ID}-api-gateway-stack

