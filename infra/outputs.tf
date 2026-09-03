output "table_name" {
  description = "Name of the DynamoDB table."
  value       = module.survey_responses_table.table_name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = module.survey_responses_table.table_arn
}

output "api_url" {
  description = "Public URL of the survey API."
  value       = module.survey_api.api_url
}
