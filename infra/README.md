# Deploying To AWS (Optional)

This folder contains the Terraform code that puts the survey backend on real
AWS infrastructure. It is not needed for the workshop session. Do the local
Docker setup in the root `README.md` first, get your endpoints working, then
come here if you want them running in the cloud.

This costs money if you leave it running. Destroy the resources when you are
done. See the last section.

## What Terraform Creates

- Amazon DynamoDB table for survey responses
- IAM role and policies for the Lambda function
- AWS Lambda function for the FastAPI backend
- Lambda Function URL for public HTTP access

The Function URL has no authentication and allows any origin, so anyone with
the URL can read and write your table. That is fine for a short demo. Do not
leave it up.

## Folder Structure

```text
infra/
  main.tf                  wires the modules together
  providers.tf             which providers Terraform uses
  variables.tf             project-level inputs
  outputs.tf               values printed after deployment
  terraform.tfvars.example

  modules/
    dynamodb/              the DynamoDB table
    iam/                   the Lambda execution role and permissions
    lambda/                the Lambda function and Function URL
```

## Prerequisites

- Terraform >= 1.5 and AWS CLI v2. The scripts in `setup/` install both.
- An AWS account with credentials configured locally.

Check your tools:

```bash
terraform version
aws --version
```

## Step 1: Get AWS Credentials

Skip to Step 2 if `aws sts get-caller-identity` already works.

### Create or access an AWS account

Create one at <https://aws.amazon.com/> if you do not have one, and sign in to
the console.

### Create an access key

You need an IAM user. If you do not have one, create it first: search for
`IAM` in the console, open `Users`, `Create user`, then attach permissions.
The identity needs to manage DynamoDB, Lambda, IAM roles and policies,
CloudWatch Logs, and Lambda Function URLs. For a throwaway workshop account
the simplest option is the `AdministratorAccess` policy. On any account you
care about, scope it down instead.

Then, for that user:

1. Open the `Security credentials` tab.
2. Scroll to `Access keys` and select `Create access key`.
3. Choose `Command Line Interface (CLI)` as the use case.
4. Confirm the warning and create the key.
5. Copy the Access Key ID and Secret Access Key.

The Secret Access Key is shown once. Never commit it, and never paste it into
a source file. This repo ignores `.env`, `.aws/`, and `*.tfvars`, but be
careful anyway.

### Configure and verify

```bash
aws configure
```

Enter the key id, the secret, `us-east-1` as the region, and `json` as the
output format. Then check it:

```bash
aws sts get-caller-identity
```

If that prints your account and identity, credentials are working.

## Step 2: Build The Lambda Package

Terraform uploads a prebuilt bundle, so this has to happen first. From the
project root:

```bash
# Run from: Survey-Webapp/
./build.sh
```

This creates the `build/` folder containing `survey.py` and its dependencies.
Terraform zips that folder into `lambda.zip` during `apply`.

`build.sh` needs Bash. On Windows, run it from Git Bash or WSL.

## Step 3: Create Your Variables File

```bash
# Run from: Survey-Webapp/infra/
cd infra
cp terraform.tfvars.example terraform.tfvars
```

The values match the defaults in `variables.tf`:

```hcl
aws_region = "us-east-1"
table_name = "survey-responses"
hash_key   = "response_id"
```

## Step 4: Deploy

```bash
# Run from: Survey-Webapp/infra/
terraform init
terraform plan
terraform apply
```

Type `yes` when Terraform asks for confirmation.

## Step 5: Review The Outputs

Terraform prints:

```text
table_name = "survey-responses"
table_arn  = "arn:aws:dynamodb:us-east-1:123456789012:table/survey-responses"
api_url    = "https://example.lambda-url.us-east-1.on.aws/"
```

Open `api_url` with `/docs` on the end to see your deployed API, and
`/health` to confirm it reached DynamoDB.

The deployed Lambda talks to real DynamoDB because `DYNAMODB_ENDPOINT` is not
set there. That variable only exists for the local Docker setup.

## Step 6: Clean Up

When you are done, from `infra/`:

```bash
terraform destroy
```

Type `yes` to confirm. To preview what will be removed first:

```bash
terraform plan -destroy
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
