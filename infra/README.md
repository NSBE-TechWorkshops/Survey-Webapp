# Workshop Infrastructure

This folder contains Terraform code for creating the AWS resources used by the survey app.

## What Terraform Creates

- Amazon DynamoDB table for survey responses
- IAM role and policies for the Lambda function
- AWS Lambda function for the FastAPI backend
- Lambda Function URL for public HTTP access

## Folder Structure

```text
infra/
  main.tf
  providers.tf
  variables.tf
  outputs.tf
  terraform.tfvars.example

  modules/
    dynamodb/
      main.tf
      variables.tf
      outputs.tf

    iam/
      main.tf
      variables.tf
      outputs.tf

    lambda/
      main.tf
      variables.tf
      outputs.tf
```

The root `infra/` folder wires the modules together.

The `modules/` folder contains one reusable module per service area:

- `dynamodb/` creates the DynamoDB table
- `iam/` creates the Lambda execution role and permissions
- `lambda/` creates the Lambda function and Function URL

## Prerequisites

Before starting, make sure you have:

- An AWS account
- AWS CLI installed
- Terraform installed
- AWS credentials configured on your machine

Check your tools:

```bash
aws --version
terraform version
```

## Step 1: Configure AWS Credentials

```bash
aws configure
```

For the default region, you can use:

```text
us-east-1
```

## Step 2: Build the Lambda Package

From the project root, run:

```bash
./build.sh
```

This creates the local `build/` folder and `lambda.zip` package that Terraform deploys to AWS Lambda.

## Step 3: Go To The Infra Folder

```bash
cd infra
```

## Step 4: Create Your Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Review the values:

```hcl
aws_region = "us-east-1"
table_name = "survey-responses"
hash_key   = "response_id"
```

## Step 5: Initialize Terraform

```bash
terraform init
```

## Step 6: Build The Lambda Package

Terraform expects the Lambda source bundle to already exist.
From the project root, run:

```bash
cd ..
./build.sh
cd infra
```

This creates `../build/` and `../lambda.zip` for the Lambda module.

## Step 7: Preview The Resources

```bash
terraform plan
```

## Step 8: Create The AWS Resources

```bash
terraform apply
```

Type `yes` when Terraform asks for confirmation.

## Step 9: Review The Outputs

Terraform prints values such as:

```text
table_name = "survey-responses"
table_arn  = "arn:aws:dynamodb:us-east-1:123456789012:table/survey-responses"
api_url    = "https://example.lambda-url.us-east-1.on.aws/"
```

## Step 10: Clean Up Resources

When you are done:

```bash
terraform destroy
```

## Useful Terraform Commands

```bash
terraform init
terraform plan
terraform apply
terraform destroy
terraform fmt -recursive
```

## Teaching Notes

- `providers.tf` tells Terraform which providers to use.
- `variables.tf` defines project-level inputs.
- `main.tf` connects the service modules together.
- `outputs.tf` prints useful values after deployment.
- Each folder in `modules/` owns one service area.
