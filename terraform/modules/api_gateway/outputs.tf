output "api_url" {
  value = aws_api_gateway_deployment.lambda_demo_api_deployment.invoke_url
}
output "execution_arn" {
  value       = aws_api_gateway_rest_api.lambda_demo_api.execution_arn
  description = "The execution ARN of the API Gateway."
}