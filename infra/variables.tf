variable "aws_region" {
  description = "AWS region where the DynamoDB table will be created."
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
  default     = "survey-responses"
}

variable "hash_key" {
  description = "Partition key for the DynamoDB table."
  type        = string
  default     = "response_id"
}
