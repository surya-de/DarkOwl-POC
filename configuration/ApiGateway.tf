resource "aws_api_gateway_rest_api" "AcceptPostReqs" {
  name = "AcceptPostReqs"
  description = "API gateway that accepts post requests"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.ApiDeployment.invoke_url}"
}