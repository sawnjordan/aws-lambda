provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

module "lambda" {
  source                    = "./modules/lambda"
  ecr_repository_url        = module.ecr.repository_url
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  api_name            = var.api_description
  api_description     = var.api_description
  stage_name          = var.stage_name
  region              = var.aws_region
  lambda_function_arn = module.lambda.lambda_function_arn
}