output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.api.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.api.arn
}

output "api_url" {
  description = "Public Lambda Function URL for the API."
  value       = aws_lambda_function_url.api.function_url
}
