resource "terraform_data" "lambda_source_check" {
  input = var.source_dir

  lifecycle {
    precondition {
      condition     = fileexists("${var.source_dir}/survey.py")
      error_message = "Lambda build output not found in ${var.source_dir}. Run ./build.sh from the project root before terraform plan/apply."
    }
  }
}

data "archive_file" "lambda" {
  depends_on  = [terraform_data.lambda_source_check]
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
}

resource "aws_lambda_function" "api" {
  function_name = var.function_name
  role          = var.role_arn

  runtime       = var.runtime
  architectures = var.architectures
  handler       = var.handler

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "function_url" {
  statement_id           = "AllowPublicFunctionUrlAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.api.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}