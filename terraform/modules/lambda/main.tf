resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# resource "aws_iam_policy" "lambda_vpc_policy" {
#   name        = "lambda-vpc-policy"
#   description = "Allow Lambda to access VPC resources"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = "ec2:CreateNetworkInterface"
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = "ec2:DescribeNetworkInterfaces"
#         Resource = "*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*"
}

resource "aws_security_group" "lambda_security_group" {
  name        = "lambda-security-group"
  description = "Allow access to Lambda function"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "get_git_commit" {
  provisioner "local-exec" {
    command = <<EOT
      CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      if [ "$CURRENT_BRANCH" = "main" ]; then
        echo "On main branch: $CURRENT_BRANCH"
        git rev-parse --short HEAD > git_commit.txt
      else
        echo "Not on main branch: $CURRENT_BRANCH."
        exit 0
      fi
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "local_file" "git_commit" {
  filename = "${path.module}/git_commit.txt"
}

# Push Docker image to ECR (this requires a local Docker setup)
resource "null_resource" "push_image_to_ecr" {
  provisioner "local-exec" {
    command = <<EOT
      export GIT_COMMIT=$(git rev-parse --short HEAD)
      $(aws ecr get-login --no-include-email --region ${var.aws_region})
      docker build -t ${var.ecr_repository_url}:$GIT_COMMIT ../
      docker push ${var.ecr_repository_url}:$GIT_COMMIT
    EOT
  }

  # triggers = {
  #   git_commit = chomp(shell("git rev-parse --short HEAD"))
  # }
  triggers = {
    git_commit = data.local_file.git_commit.content
  }

  depends_on = [var.ecr_repository_url]
}

resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name

  role      = aws_iam_role.lambda_execution_role.arn
  image_uri = "${var.ecr_repository_url}:${null_resource.push_image_to_ecr.triggers.git_commit}"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }

  depends_on = [null_resource.push_image_to_ecr]
}