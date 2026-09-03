variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "Partition key for the DynamoDB table."
  type        = string
}
