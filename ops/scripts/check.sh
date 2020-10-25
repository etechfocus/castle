#!/bin/bash

set -x
export AWS_PAGER=""
BASEDIR=`dirname $0`/../..

aws cloudformation list-stacks --query 'StackSummaries[*].[StackName, StackStatus]' --stack-status-filter CREATE_IN_PROGRESS CREATE_COMPLETE --output table
