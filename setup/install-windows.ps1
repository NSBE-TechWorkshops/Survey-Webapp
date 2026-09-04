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
Install-WingetPackage -Id "Docker.DockerDesktop" -Name "Docker Desktop" -Command "docker"

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
Write-Host "1. Run: aws configure"
Write-Host "2. Copy .env.example to .env and infra\terraform.tfvars.example to infra\terraform.tfvars"
Write-Host "3. Run: bash ./build.sh, or use Git Bash/WSL if Bash is not available"
Write-Host "4. Run Terraform commands from infra\README.md"
Write-Host ""
Write-Host "If Docker was just installed, open Docker Desktop once before running docker compose."
