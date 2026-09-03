variable "role_name" {
  description = "Name of the IAM role used by the Lambda function."
  type        = string
  default     = "survey-api-lambda-role"
}

variable "dynamodb_policy_name" {
  description = "Name of the inline IAM policy that allows Lambda to access DynamoDB."
  type        = string
  default     = "survey-api-dynamodb-access"
}

variable "table_arn" {
  description = "ARN of the DynamoDB table the Lambda function can access."
  type        = string
}
