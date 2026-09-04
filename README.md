# Survey App

This project contains a FastAPI backend, Terraform infrastructure, and a Docker setup for running the backend locally.

## Install prerequisites

Before running the app or deploying infrastructure, install the required tools with the setup scripts in `setup/`.

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

## Run the backend locally with Docker

The Dockerfile installs `requirements-dev.txt`, which includes `boto3`, so the backend can connect to AWS DynamoDB from inside the container.

### 1. Configure AWS credentials

Make sure you have AWS credentials configured on your machine:

```bash
aws configure
```

### 2. Create the DynamoDB table

From the `infra/` folder, create the AWS resources:

```bash
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
## Run the backend locally (no Docker)

```bash
pip install -r requirements-dev.txt
./run.sh
```

Then open http://localhost:8000/docs

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

## Notes

- Docker is for local development/testing.
- AWS Lambda deployment still uses `build.sh` and Terraform.
- The container connects to real AWS DynamoDB using your local AWS credentials mounted into the container.
