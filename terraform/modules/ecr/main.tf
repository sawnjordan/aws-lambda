resource "aws_ecr_repository" "lambda_repo" {
  name = var.repository_name
}

output "repository_url" {
  value = aws_ecr_repository.lambda_repo.repository_url
}
