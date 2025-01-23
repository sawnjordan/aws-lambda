variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the Lambda function"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

# variable "lambda_image_tag" {
#   description = "The Docker image tag for the Lambda function"
#   type        = string
# }

variable "lambda_function_name" {
  description = "The name for Lambda function"
  type        = string
  default     = "LambdaDemoFunction"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}
variable "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway linked to the Lambda function."
  type        = string
}