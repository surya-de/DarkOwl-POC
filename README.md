# DarkOwl-POC
DarkOwl coding assessment

## Pre Requisites

## How to start

## Runner Policy
* iam:CreateRole
* iam:PutRolePolicy
* dynamodb:CreateTable
* dynamodb:TagResource
* dynamodb:DescribeTable
* dynamodb:DescribeContinuousBackups
* dynamodb:DescribeTimeToLive
* dynamodb:ListTagsOfResource
* dynamodb:DeleteTable
* logs:CreateLogGroup
* logs:PutRetentionPolicy
* logs:ListTagsLogGroup
* logs:DeleteLogGroup

scp -i "DarkOwl.pem" -r DarkOwl-POC/configuration ubuntu@ec2-18-118-51-70.us-east-2.compute.amazonaws.com:/home/ubuntu/DarkOwl-POC/

curl -v -X "POST" -H "Content-Type: application/json" -d "{\"Value\": \"12369845021\"}" https://d6rkyqcj56.execute-api.us-west-2.amazonaws.com/DarkOwlPOC