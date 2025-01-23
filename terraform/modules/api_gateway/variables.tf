variable "api_name" {
  type        = string
  description = "The name of the API Gateway"
  default     = "DemoAPIKey"
}

variable "api_description" {
  type        = string
  description = "The description of the API Gateway"
  default     = "API key for accessing the Python application"
}

variable "stage_name" {
  type        = string
  description = "The deployment stage name"
  default     = "prod"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function"
}
