module "survey_responses_table" {
  source = "./modules/dynamodb"

  table_name = var.table_name
  hash_key   = var.hash_key
}

module "lambda_iam" {
  source = "./modules/iam"

  table_arn = module.survey_responses_table.table_arn
}

module "survey_api" {
  source = "./modules/lambda"

  role_arn    = module.lambda_iam.role_arn
  table_name  = module.survey_responses_table.table_name
  source_dir  = "${path.module}/../build"
  output_path = "${path.module}/../lambda.zip"
}
