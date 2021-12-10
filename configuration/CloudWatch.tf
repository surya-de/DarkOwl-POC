resource "aws_cloudwatch_log_group" "LambdaLogs" {
  name = "/aws/lambda/${aws_lambda_function.ProcessAPIRequest.function_name}"
  retention_in_days = 14
}
