provider "aws" {
  region = "us-west-2"
}

resource "aws_lambda_function" "ProcessAPIRequest" {
  filename = "lambda_deployment_pkg.zip"
  function_name = "ProcessAPIRequest"
    s3_bucket = "deploymentstorage-darkowl"
  s3_key = "lambda_deployment_pkg.zip"
  handler = "ApiHandler.lambda_handler"
  role = "${aws_iam_role.lambda_exec.arn}"
  description = "Lmabda Funcion to accespt API req and populate DynamoDB"
  runtime = "python3.7"
  tags = {
    purpose = "DarkOwl-POC"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaRole_API-DynamoDB"
  assume_role_policy = file("TrustRelationship.json")
}

resource "aws_iam_role_policy" "LambdaPolicy_API-DynamoDB" {
  name = "LambdaPolicy_API-DynamoDB"
  policy = file("LambdaPolicy.json")
  role = "${aws_iam_role.lambda_exec.id}"
}

scp -i "DarkOwl.pem" -r DarkOwl-POC/configuration ubuntu@ec2-18-118-51-70.us-east-2.compute.amazonaws.com:/home/ubuntu/DarkOwl-POC/

