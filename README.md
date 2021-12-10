# DrakOwl-POC
This is a small POC to automate configuration and deployment of a serverless architecture. The project consists of the following components-
* **API Gateway**: Used to accept a 10-digit number from client.
* **AWS Lambda**: The Lambda process the raw data and pushes it into Dynamo DB.
* **DynamoDB**: Used to store the processed data pushed by the client.

In this project I have used terraform and Python to automate and imlement the architecture.

## Requirements
* Ubuntu/ Mac OS
* Python >= 3.5
* Terraform >=V1.0.11
* AWS CLI >=1.18.69
* zip >=3.0

## Assumptions
In order to implement I have made the following assumptions-
* A runner instance/system is available with git and aws cli configured.
* Because of time constraints I have no considered scenarios to validate data insertion after an interval to avoid data loss. (I will discuss more about it in the improvemen section)
* I have assumes that we will not be inserting more that 10 items in the dynamoDb per second.

## Folder Structure
```
  - DarkOwl                           ## The root of the project.
    |- configurations                 ## The folder which contains all the configuration scripts(Terraform).
      |- Policies                     ## This sub folder contains JSON files for the IAM roles and Policies.
        |- LambdaPolicy.json          ## This is the IAM policy JSON that grants Lambda access to put items in Dynamo DB.
        |- TrustRelationship.json     ## This is the IAM policy JSON that allows Lambda to assume the role. 
      |- ApiGateway.tf                ## IAC script for API gateway configuration.
      |- CloudWatch.tf                ## IAC script for cloudwatch configuration.
      |- DynamoDb.tf                  ## IAC script for DynamoDB configuration.
      |- LmbdaFunctio.tf              ## IAC script for Lambda FUnction configuration.
    |- res                            ## The resources folder which is used to store architectural diagrams for Readme file.
    |- **APIHandler.py**              ## This is the main lambda function which is responsible for data processing and putting item into DB.
    |- Readme.md                      ## The Readme file
    
```
## Steps to run the POC
* On your local sytem/ EC2 clone the repository
```bash
git clone https://github.com/surya-de/DarkOwl-POC.git
```
* 
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
