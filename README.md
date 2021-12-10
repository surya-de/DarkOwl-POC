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
* By default I have set the region to `us-west-2`.
* Due to the time constraint I have used `Default VPC` for all the resources.
* Because of time constraints I have no considered scenarios to validate data insertion after an interval to avoid data loss. (I will discuss more about it in the improvemen section)
* I have assumes that we will not be inserting more that 10 items in the dynamoDb per second.

## Folder Structure
```
  - DarkOwl-POC                       ## The root of the project.
    |- configurations                 ## The folder which contains all the configuration scripts(Terraform).
      |- Policies                     ## This sub folder contains JSON files for the IAM roles and Policies.
        |- LambdaPolicy.json          ## This is the IAM policy JSON that grants Lambda access to put items in Dynamo DB.
        |- TrustRelationship.json     ## This is the IAM policy JSON that allows Lambda to assume the role. 
      |- ApiGateway.tf                ## IAC script for API gateway configuration.
      |- CloudWatch.tf                ## IAC script for cloudwatch configuration.
      |- DynamoDb.tf                  ## IAC script for DynamoDB configuration.
      |- LmbdaFunctio.tf              ## IAC script for Lambda FUnction configuration.
    |- res                            ## The resources folder which is used to store architectural diagrams for Readme file.
    |- APIHandler.py                  ## This is the main lambda function which is responsible for data processing and putting item into DB.
    |- Readme.md                      ## The Readme file
    
```
## Steps to run the POC
* On your local sytem/ EC2 clone the repository
```bash
git clone https://github.com/surya-de/DarkOwl-POC.git
```
* Once the repository is cloned. Perform the following steps-
```bash
cd DarkOwl-POC
cd configuration
```
* you are now inside the ``configurations`` folder which holds all the terraform files. Do the following steps to initialize and validate the scripts-
```bash
terraform init
terraform validate
```
* Now that terraform is initialised and validated, lets create a deployment package(zip) for the lambda function(``DarkOwl-POC/APIHandler.py``) and sore it here ``DarkOwl-POC/configurations``
```bash
zip lambda_deployment_pkg.zip ../APIHandler.py
```
* The pervious step should create a file `lambda_deployment_pkg.zip` in the following path- `DarkOwl-POC/configurations`
* Now that the deployment package is ready, we are all set to run the terraform scripts-
```Bash
terraform apply
```
Once this is done, terraform will show a summary of resources that are to be created and will ask for a validation. Once prompted we need to allow the process by typing `yes`. This validation step can be avoided by using this scriot-
```bash
terraform apply -auto-approve
```
* On successful completion of this step, our AWS infrastructure will be ready and we can test our pipeline. The API endpoint can be found at the end of the execution.

## Set Up Information
1. One can use IAM users or IAM Roles(`If using ec2`) to run the steps mentioned above. Please make sure the following permissions are attached to the IAM user or IAM Role before doing the above steps.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:PutRolePolicy",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:GetPolicyVersion",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "apigateway:*",
                "dynamodb:CreateTable",
                "dynamodb:TagResource",
                "dynamodb:DescribeTable",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTagsOfResource",
                "dynamodb:DeleteTable",
                "logs:CreateLogGroup",
                "logs:PutRetentionPolicy",
                "logs:DescribeLogGroups",
                "logs:ListTagsLogGroup",
                "logs:DeleteLogGroup",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "execute-api:Invoke",
                "execute-api:ManageConnections",
                "xray:GetTraceSummaries",
                "xray:BatchGetTraces",
                "tag:GetResources",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:ListAliases"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "lambda.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/*"
        }
    ]
}
```

2. If you are using IAM User. Please make sure to configure the aws cli by adding AWS Access key and AWS Access ID.
```bash
aws configure
AWS Access Key ID [None]: ENTER AWS-ACCESS-KEY-ID
AWS Secret Access Key [None]: ENTER AWS-SECRET-ACCESS-KEY-ID
```

## Test the API
Once the IAC runs successfully we can find the API endpoint on the CLI. We can use the follwing command to test our endpoint-
```bash
curl -v -X "POST" -H "Content-Type: application/json" -d "{\"Value\": \"12369845021\"}" https://REPLACE/WITH/API/ENDPOINT/URL
```
