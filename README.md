# Survey App

This project contains a FastAPI backend, Terraform infrastructure, and a Docker setup for running the backend locally.

## Install prerequisites

Before running the app or deploying infrastructure, install the required tools with the setup scripts in `setup/`.

The setup scripts install Docker and Docker Compose. You can also install Docker Desktop manually if you prefer, especially on macOS or Windows. If Docker Desktop was just installed, open it once before running `docker compose`.

macOS/Linux:

```bash
chmod +x setup/install-unix.sh
./setup/install-unix.sh
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\install-windows.ps1
```

See `setup/README.md` for details about what gets installed and platform-specific notes.

## Update your local copy

If you cloned this repo during a previous workshop session, run `git pull` first so your local copy has the latest setup scripts and README changes.

```bash
git pull
```

If you just cloned the repo for the first time, you can skip this step.

## AWS account and credentials

If you already have an AWS account and local AWS credentials configured, skip ahead to the next section.

Terraform uses your local AWS credentials to create the AWS resources for this project. The project's Lambda execution role is created automatically by the Terraform IAM module, so you do not need to manually create the Lambda role.

### 1. Create or access an AWS account

Create an AWS account at <https://aws.amazon.com/> if you do not already have one.

### 2. Sign in to the AWS Console

Open the AWS Console and confirm that you can access the account you plan to use.

### 3. Set up local AWS access

For this workshop/local setup, use an IAM user access key.

In the AWS Console:

1. Search for `IAM`.
2. Open `Users`.
3. Select your IAM user.
4. Open the `Security credentials` tab.
5. Scroll to `Access keys`.
6. Select `Create access key`.
7. Choose `Command Line Interface (CLI)` as the use case.
8. Confirm the warning and create the key.
9. Copy the Access Key ID and Secret Access Key.

The Secret Access Key is only shown once. Keep it somewhere safe while you finish setup, and do not commit it to this repo.

The AWS identity you use locally needs enough permissions for Terraform to manage DynamoDB, Lambda, IAM roles and policies, CloudWatch Logs, and Lambda Function URLs.

### 4. Configure credentials locally

For access keys, run:

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, default region, and output format. Use `us-east-1` as the default region unless your team says otherwise. `json` is a good default output format.

### 5. Verify your credentials

Run:

```bash
aws sts get-caller-identity
```

If this prints your AWS account and identity information, your credentials are working.

Do not commit AWS access keys or secrets. Do not paste secrets into source files. This repo ignores `.env`, `.aws/`, and Terraform variable files, but you should still be careful with credentials.

## Project setup flow

After prerequisites and AWS credentials are ready, use this order:

1. Run `git pull` if you cloned this repo during a previous workshop session.
2. Create your local config files.
3. Run `./build.sh` from the project root.
4. Run the Terraform commands from `infra/`.
5. Run the backend locally with Docker Compose, or use `./run.sh` if you do not want to use Docker.

`build.sh` creates the Lambda deployment package that Terraform uploads to AWS. Run it before `terraform plan` or `terraform apply`.

`run.sh` starts the local FastAPI development server with Uvicorn. It is only needed for the no-Docker local workflow and is not required for Terraform deployment.

## Run the backend locally with Docker

Docker is recommended for this workshop because it gives everyone a consistent local environment.

The Dockerfile installs `requirements-dev.txt`, which includes `boto3`, so the backend can connect to AWS DynamoDB from inside the container.

### 1. Configure AWS credentials

Make sure you have completed the `AWS account and credentials` section above. As a quick reminder, access-key based setup uses:

```bash
aws configure
```

### 2. Create the DynamoDB table

From the project root, build the Lambda package first. Then create the AWS resources from the `infra/` folder:

```bash
./build.sh

cd infra
terraform init
terraform apply
cd ..
```

### 3. Create your environment file

From the project root, copy the example file:

```bash
cp .env.example .env
```

The `.env` file contains local app config:

```env
AWS_REGION=us-east-1
TABLE_NAME=survey-responses
```

### 4. Run the backend with Docker Compose

From the project root:

```bash
docker compose up --build
```

Docker Compose will:

- build the backend image from the `Dockerfile`
- load environment variables from `.env`
- mount your local AWS credentials into the container
- expose the backend on port `8000`

To stop the backend, press `Ctrl+C`.

If you want to run it in the background instead:

```bash
docker compose up --build -d
```

Then stop it with:

```bash
docker compose down
```

Then open:

```text
http://localhost:8000/docs
```

## Run the backend locally without Docker

Use this option only if you do not want to use Docker. The `run.sh` script starts the local FastAPI development server with Uvicorn and is not required for Terraform deployment.

```bash
pip install -r requirements-dev.txt
./run.sh
```

Then open <http://localhost:8000/docs>

## Clean up AWS resources

This is a demo/workshop project. When you are done testing, destroy the AWS resources so they do not keep running or create unexpected AWS charges.

From the project root, run:

```bash
cd infra
terraform destroy
cd ..
```

Type `yes` when Terraform asks for confirmation.

If you want to preview what Terraform will remove before destroying anything, run:

```bash
cd infra
terraform plan -destroy
cd ..
```

## Notes

- Docker is for local development/testing.
- AWS Lambda deployment still uses `build.sh` and Terraform.
- The container connects to real AWS DynamoDB using your local AWS credentials mounted into the container.
- Because this is a demo app, destroy the Terraform resources when you are done testing.
