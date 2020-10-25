#!/bin/bash
set -x #echo on

PROJECT_ID='pepper'
while getopts "p:" opt; do
    case $opt in
        p) PROJECT_ID=$OPTARG;;
        *)
        exit 1;;
    esac
done

export PEPPER_EMAIL=test@example.com
export PEPPER_PASSWORD=S3cureXYZA#

export PEPPER_CLIENT_ID=`aws cloudformation describe-stacks --stack-name ${PROJECT_ID}-cognito-stack | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="UserPoolClientId")|.OutputValue'`
export PEPPER_POOL_ID=`aws cloudformation describe-stacks --stack-name ${PROJECT_ID}-cognito-stack | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="UserPoolId")|.OutputValue'`
export PEPPER_API_URL=`aws cloudformation describe-stacks --stack-name ${PROJECT_ID}-api-gateway-stack | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="ApiURL")|.OutputValue'`

env | grep PEPPER

# create user
aws cognito-idp sign-up --client-id ${PEPPER_CLIENT_ID} --username ${PEPPER_EMAIL} --password ${PEPPER_PASSWORD} 
aws cognito-idp admin-confirm-sign-up --user-pool-id ${PEPPER_POOL_ID} --username ${PEPPER_EMAIL}

# test auth api
TOKEN=$(aws cognito-idp initiate-auth \
    --client-id ${PEPPER_CLIENT_ID} \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME=${PEPPER_EMAIL},PASSWORD=${PEPPER_PASSWORD} \
    --query 'AuthenticationResult.IdToken' \
    --output text)

echo ${TOKEN}

# test api gateway
curl -X POST $PEPPER_API_URL
curl -X POST -H "Authorization: Bearer ${TOKEN}" $PEPPER_API_URL

# show db content
aws dynamodb scan --table-name=pepper_accounts

# sqs
export PEPPER_QUEUE_URL=`aws sqs list-queues | jq -r '.QueueUrls[0]'`
aws sqs receive-message --queue-url=${PEPPER_QUEUE_URL}

export PEPPER_KINESIS_SHARD_ID=`aws kinesis describe-stream --stream-name=pepper-kinesis-stack-stream | jq -r '.StreamDescription.Shards[0].ShardId'`
export PEPPER_KINESIS_SHARD_ITERATOR=`aws kinesis get-shard-iterator --stream-name=pepper-kinesis-stack-stream --shard-id=${PEPPER_KINESIS_SHARD_ID} --shard-iterator-type=LATEST | jq -r '.ShardIterator'`

aws kinesis get-records --shard-iterator=${PEPPER_KINESIS_SHARD_ITERATOR}
