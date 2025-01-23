variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "lambda-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["aps1-az1", "aps1-az2"]
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "lambda_demo_repo"
}

# variable "lambda_image_tag" {
#   description = "The Docker image tag for the Lambda function"
#   type        = string
# }

variable "api_name" {
  type        = string
  description = "The name of the API Gateway"
  default     = "lambda_demo_api"
}

variable "api_description" {
  type        = string
  description = "The description of the API Gateway"
  default     = "Lambda Test Demo"
}

variable "stage_name" {
  type        = string
  description = "The deployment stage name"
  default     = "prod"
}
