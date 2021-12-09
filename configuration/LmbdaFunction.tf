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

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  parent_id = "${aws_api_gateway_rest_api.AcceptPostReqs.root_resource_id}"
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "POST"
  authorization = "None"
}

resource "aws_api_gateway_integration" "LambdaIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.ProcessAPIRequest.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  resource_id   = "${aws_api_gateway_rest_api.AcceptPostReqs.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "LambdaIntegration_root" {
  rest_api_id = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.ProcessAPIRequest.invoke_arn}"
}

resource "aws_api_gateway_deployment" "ApiDeployment" {
  depends_on = [
    "aws_api_gateway_integration.LambdaIntegration",
    "aws_api_gateway_integration.LambdaIntegration_root",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.AcceptPostReqs.id}"
  stage_name = "DarkOwlPOC"
}

resource "aws_lambda_permission" "AllowPermission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ProcessAPIRequest.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.AcceptPostReqs.execution_arn}/*/*"
}