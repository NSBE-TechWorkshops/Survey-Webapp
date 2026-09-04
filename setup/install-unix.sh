#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OS="$(uname -s)"

info() {
  printf '\n==> %s\n' "$1"
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

select_python() {
  if has_command python3.12; then
    printf 'python3.12'
    return 0
  fi

  if has_command python3 && python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)' >/dev/null 2>&1; then
    printf 'python3'
    return 0
  fi

  return 1
}

install_macos() {
  if ! has_command brew; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  info "Installing prerequisites with Homebrew"
  brew update
  brew install python@3.12 terraform awscli

  if ! has_command docker; then
    brew install --cask docker
    info "Docker Desktop was installed. Open Docker Desktop once before using docker compose."
  else
    info "Docker already installed: $(docker --version)"
  fi
}

install_linux() {
  if has_command apt-get; then
    info "Installing prerequisites with apt"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release unzip python3 python3-pip python3-venv docker.io docker-compose-plugin

    if apt-cache show python3.12 >/dev/null 2>&1; then
      sudo apt-get install -y python3.12 python3.12-venv
    fi

    if ! has_command terraform; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
      sudo apt-get update
      sudo apt-get install -y terraform
    fi
  elif has_command dnf; then
    info "Installing prerequisites with dnf"
    sudo dnf install -y dnf-plugins-core curl unzip python3 python3-pip docker docker-compose-plugin
    sudo dnf install -y python3.12 python3.12-pip || true
    if ! has_command terraform; then
      sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
      sudo dnf install -y terraform
    fi
  elif has_command yum; then
    info "Installing prerequisites with yum"
    sudo yum install -y yum-utils curl unzip python3 python3-pip docker
    if ! has_command terraform; then
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum install -y terraform
    fi
  elif has_command pacman; then
    info "Installing prerequisites with pacman"
    sudo pacman -Sy --needed --noconfirm python python-pip terraform aws-cli docker docker-compose
  elif has_command zypper; then
    info "Installing prerequisites with zypper"
    sudo zypper install -y python3 python3-pip terraform aws-cli docker docker-compose
  else
    printf 'Unsupported Linux package manager. Install Python 3.12, pip, Terraform >= 1.5, AWS CLI v2, and Docker manually.\n' >&2
    exit 1
  fi

  if ! has_command aws; then
    info "Installing AWS CLI v2"
    tmpdir="$(mktemp -d)"
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "$tmpdir/awscliv2.zip"
    unzip -q "$tmpdir/awscliv2.zip" -d "$tmpdir"
    sudo "$tmpdir/aws/install" --update
    rm -rf "$tmpdir"
  fi

  if has_command systemctl; then
    sudo systemctl enable --now docker || true
  fi

  if has_command usermod && ! groups "$USER" | grep -q '\bdocker\b'; then
    info "Adding $USER to the docker group. Log out and back in before running Docker without sudo."
    sudo usermod -aG docker "$USER" || true
  fi
}

install_python_deps() {
  info "Installing project Python dependencies"
  cd "$PROJECT_ROOT"

  if python_cmd="$(select_python)"; then
    "$python_cmd" -m pip install --upgrade pip
    "$python_cmd" -m pip install -r requirements-dev.txt
  else
    printf 'Python 3.12 was not found after installation. Install Python 3.12 manually and rerun this script.\n' >&2
    exit 1
  fi
}

verify() {
  info "Installed tool versions"
  if python_cmd="$(select_python)"; then
    "$python_cmd" --version || true
    "$python_cmd" -m pip --version || true
  fi
  terraform version || true
  aws --version || true
  docker --version || true
  docker compose version || true

  printf '\nNext steps:\n'
  printf '1. Run: aws configure\n'
  printf '2. Copy .env.example to .env and infra/terraform.tfvars.example to infra/terraform.tfvars\n'
  printf '3. Run: ./build.sh\n'
  printf '4. Run Terraform commands from infra/README.md\n'
}

case "$OS" in
  Darwin)
    install_macos
    ;;
  Linux)
    install_linux
    ;;
  *)
    printf 'Unsupported OS: %s. Use setup/install-windows.ps1 on Windows.\n' "$OS" >&2
    exit 1
    ;;
esac

install_python_deps
verify
