variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "survey-api"
}

variable "role_arn" {
  description = "ARN of the IAM role used by the Lambda function."
  type        = string
}

variable "runtime" {
  description = "Python runtime for the Lambda function."
  type        = string
  default     = "python3.12"
}

variable "architectures" {
  description = "CPU architecture used by the Lambda function."
  type        = list(string)
  default     = ["arm64"]
}

variable "handler" {
  description = "Lambda handler path."
  type        = string
  default     = "survey.handler"
}

variable "source_dir" {
  description = "Directory containing the built Lambda package contents."
  type        = string
}

variable "output_path" {
  description = "Path where Terraform should write the Lambda zip file."
  type        = string
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 512
}

variable "table_name" {
  description = "DynamoDB table name exposed to the Lambda function as an environment variable."
  type        = string
}
