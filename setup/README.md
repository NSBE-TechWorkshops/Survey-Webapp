# Setup Scripts

Use these scripts to install the system tools for this project.

For the workshop itself you only need Git and Docker. These scripts also
install Terraform, the AWS CLI, and Python 3.12 for the optional AWS
deployment track.

## What Gets Installed

- Python 3.12 and pip
- Project Python dependencies from `requirements-dev.txt`
- Terraform `>= 1.5`
- AWS CLI v2
- Docker and Docker Compose, which is how the workshop app runs

## macOS and Linux

From the project root, run:

```bash
chmod +x setup/install-unix.sh
./setup/install-unix.sh
```

The script detects macOS or Linux automatically.

On macOS, it uses Homebrew. If Homebrew is missing, the script installs it first.

If you would rather install Docker by hand on macOS, use the cask, not the
formula:

```bash
brew install --cask docker-desktop
```

`brew install docker` without `--cask` gives you the CLI with no engine, and
every command then fails with `Cannot connect to the Docker daemon`. Open
Docker Desktop once after installing, then check with `docker compose version`.

On Linux, it supports common package managers including `apt`, `dnf`, `yum`, `pacman`, and `zypper`.

## Windows

From PowerShell in the project root, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\install-windows.ps1
```

The Windows script uses `winget`. If `winget` is missing, install App Installer from the Microsoft Store and rerun the script.

If Docker Desktop was just installed, open Docker Desktop once before running `docker compose`.

## After Installing

Nothing else is required for the workshop. Go back to the root `README.md`
and run `docker compose up --build`.

The Terraform and AWS CLI tools installed here are only used by the optional
deployment track in `infra/README.md`.

## Notes

- Docker is what the workshop app runs on. Everything else here is for the optional AWS track.
- On Linux, you may need to log out and back in after the script adds your user to the `docker` group.
- On Windows, use Git Bash or WSL for Bash scripts such as `build.sh` if Bash is not available in PowerShell.
