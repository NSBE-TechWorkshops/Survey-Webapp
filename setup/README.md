# Setup Scripts

Use these scripts to install the system tools needed for this project.

## What Gets Installed

- Python 3.12 and pip
- Project Python dependencies from `requirements-dev.txt`
- Terraform `>= 1.5`
- AWS CLI v2
- Docker and Docker Compose for the optional Docker workflow

## macOS and Linux

From the project root, run:

```bash
chmod +x setup/install-unix.sh
./setup/install-unix.sh
```

The script detects macOS or Linux automatically.

On macOS, it uses Homebrew. If Homebrew is missing, the script installs it first.

On Linux, it supports common package managers including `apt`, `dnf`, `yum`, `pacman`, and `zypper`.

## Windows

From PowerShell in the project root, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\install-windows.ps1
```

The Windows script uses `winget`. If `winget` is missing, install App Installer from the Microsoft Store and rerun the script.

If Docker Desktop was just installed, open Docker Desktop once before running `docker compose`.

## After Installing

Configure your AWS credentials:

```bash
aws configure
```

Create local config files:

```bash
cp .env.example .env
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Build the Lambda package:

```bash
./build.sh
```

Then follow the Terraform steps in `infra/README.md`.

## Notes

- Docker is only required if you want to run the app with Docker Compose.
- On Linux, you may need to log out and back in after the script adds your user to the `docker` group.
- On Windows, use Git Bash or WSL for Bash scripts such as `build.sh` if Bash is not available in PowerShell.
