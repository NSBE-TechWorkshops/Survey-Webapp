output "role_name" {
  description = "Name of the Lambda execution role."
  value       = aws_iam_role.lambda_exec.name
}

output "role_arn" {
  description = "ARN of the Lambda execution role."
  value       = aws_iam_role.lambda_exec.arn
}
