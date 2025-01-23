resource "aws_api_gateway_rest_api" "lambda_demo_api" {
  name        = var.api_name
  description = var.api_description
}

resource "aws_api_gateway_resource" "list_games" {
  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_demo_api.root_resource_id
  path_part   = "list-games"
}

resource "aws_api_gateway_method" "list_games" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id      = aws_api_gateway_resource.list_games.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

}

resource "aws_api_gateway_resource" "create_game" {
  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_demo_api.root_resource_id
  path_part   = "create-game"
}

resource "aws_api_gateway_method" "create_game" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id      = aws_api_gateway_resource.create_game.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

}

resource "aws_api_gateway_resource" "update_game" {
  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_demo_api.root_resource_id
  path_part   = "update-game"
}

resource "aws_api_gateway_method" "update_game" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id      = aws_api_gateway_resource.update_game.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true

}

resource "aws_api_gateway_resource" "external_call" {
  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_demo_api.root_resource_id
  path_part   = "external-call"
}

resource "aws_api_gateway_method" "external_call" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id      = aws_api_gateway_resource.external_call.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "list_games_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id             = aws_api_gateway_resource.list_games.id
  http_method             = aws_api_gateway_method.list_games.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_integration" "create_game_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id             = aws_api_gateway_resource.create_game.id
  http_method             = aws_api_gateway_method.create_game.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_integration" "update_game_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id             = aws_api_gateway_resource.update_game.id
  http_method             = aws_api_gateway_method.update_game.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_integration" "external_call_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_demo_api.id
  resource_id             = aws_api_gateway_resource.external_call.id
  http_method             = aws_api_gateway_method.external_call.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_deployment" "lambda_demo_api_deployment" {
  depends_on = [
    aws_api_gateway_method.list_games,
    aws_api_gateway_method.create_game,
    aws_api_gateway_method.update_game,
    aws_api_gateway_method.external_call,
    aws_api_gateway_integration.list_games_integration,
    aws_api_gateway_integration.create_game_integration,
    aws_api_gateway_integration.update_game_integration,
    aws_api_gateway_integration.external_call_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  # stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }
}

# Define the stage
resource "aws_api_gateway_stage" "lambda_demo_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_demo_api.id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.lambda_demo_api_deployment.id
}

# Create an API Gateway API Key
resource "aws_api_gateway_api_key" "api_key" {
  name        = "DemoAPIKey"
  description = "API key for accessing the Python application"
  enabled     = true
}

# Create a Usage Plan
resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "DemoAPIUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.lambda_demo_api.id
    stage  = aws_api_gateway_stage.lambda_demo_api_stage.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 2
    period = "WEEK"
  }
  throttle_settings {
    burst_limit = 10
    rate_limit  = 5
  }
}

# Associate the API Key with the Usage Plan
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

# Attach the Usage Plan to your API Gateway
resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.lambda_demo_api.id
  stage_name  = aws_api_gateway_stage.lambda_demo_api_stage.stage_name

  method_path = "/*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_rate_limit  = 10
    throttling_burst_limit = 5
  }
}