$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message"
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Command
    )

    if ($Command -and (Test-Command $Command)) {
        Write-Host "$Name already installed."
        return
    }

    Write-Step "Installing $Name"
    winget install --id $Id --exact --accept-source-agreements --accept-package-agreements
}

function Test-Python312 {
    if (Test-Command py) {
        py -3.12 --version *> $null
        if ($LASTEXITCODE -eq 0) { return $true }
    }

    if (Test-Command python) {
        python -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)" *> $null
        if ($LASTEXITCODE -eq 0) { return $true }
    }

    return $false
}

if (-not (Test-Command winget)) {
    Write-Error "winget is required. Install App Installer from the Microsoft Store, then rerun this script."
}

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

if (Test-Python312) {
    Write-Host "Python 3.12 already installed."
} else {
    Write-Step "Installing Python 3.12"
    winget install --id "Python.Python.3.12" --exact --accept-source-agreements --accept-package-agreements
}

Install-WingetPackage -Id "Hashicorp.Terraform" -Name "Terraform" -Command "terraform"
Install-WingetPackage -Id "Amazon.AWSCLI" -Name "AWS CLI v2" -Command "aws"

# Docker Desktop needs WSL 2 on Windows, and installing WSL requires a reboot.
# Check it before Docker so nobody discovers this on workshop day.
Write-Step "Checking WSL 2"
wsl --status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL is not set up. Docker Desktop needs it."
    Write-Host "Open PowerShell AS ADMINISTRATOR, run:  wsl --install"
    Write-Host "Then RESTART your computer and run this script again."
    Write-Host "Do this before the workshop. The restart is not optional."
} else {
    Write-Host "WSL is available."
}

# Check for the app itself, not a `docker` command. A docker CLI can exist
# (from WSL or another install) with no engine behind it, and testing for the
# command would skip this install and leave every docker command failing.
$DockerDesktopExe = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
if (Test-Path $DockerDesktopExe) {
    Write-Host "Docker Desktop already installed."
} else {
    Write-Step "Installing Docker Desktop"
    winget install --id "Docker.DockerDesktop" --exact --accept-source-agreements --accept-package-agreements
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Step "Installing project Python dependencies"
Set-Location $ProjectRoot

if (Test-Command py) {
    py -3.12 -m pip install --upgrade pip
    py -3.12 -m pip install -r requirements-dev.txt
} elseif (Test-Command python) {
    python -m pip install --upgrade pip
    python -m pip install -r requirements-dev.txt
} else {
    Write-Error "Python was not found after installation. Restart PowerShell and rerun this script."
}

Write-Step "Installed tool versions"
if (Test-Command python) { python --version }
if (Test-Command pip) { pip --version }
if (Test-Command terraform) { terraform version }
if (Test-Command aws) { aws --version }
if (Test-Command docker) {
    docker --version
    docker compose version
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Open Docker Desktop once and wait for it to finish starting."
Write-Host "2. Check it works:  docker compose version"
Write-Host "3. From the project root, run:  docker compose up --build"
Write-Host "4. Open http://localhost:8000/docs"
Write-Host ""
Write-Host "That is all the workshop needs. Terraform and the AWS CLI installed"
Write-Host "here are only for the optional deployment track in infra\README.md."
