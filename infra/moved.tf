moved {
  from = aws_iam_role.lambda_exec
  to   = module.lambda_iam.aws_iam_role.lambda_exec
}

moved {
  from = aws_iam_role_policy.dynamodb_access
  to   = module.lambda_iam.aws_iam_role_policy.dynamodb_access
}

moved {
  from = aws_iam_role_policy_attachment.lambda_logs
  to   = module.lambda_iam.aws_iam_role_policy_attachment.lambda_logs
}

moved {
  from = aws_lambda_function.api
  to   = module.survey_api.aws_lambda_function.api
}

moved {
  from = aws_lambda_function_url.api
  to   = module.survey_api.aws_lambda_function_url.api
}