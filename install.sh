#!/bin/bash

# Kubernetes Deployment Environment Setup Script
# Supports Ubuntu/Debian and RHEL/CentOS/Fedora systems

set -euo pipefail  # Exit on error, unset var, and piped failures

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output functions
print_status()  { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Warn if script is run as root
if [ "$(id -u)" -eq 0 ]; then
    print_warning "Running as root is not recommended for Python virtual environments."
    print_warning "Consider running without sudo for virtual environment setup."
fi

detect_os_family() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID_LIKE:-$ID}"
    else
        print_error "Cannot determine OS family. Supported: Ubuntu, Debian, RHEL, CentOS, Fedora."
        exit 1
    fi
}

install_system_packages() {
    print_header "Installing System Packages"
    local os_family="$1"

    case "$os_family" in
        *debian*|*ubuntu*)
            print_status "Using apt for package installation..."
            sudo apt update > /dev/null
            sudo apt install -y python3 python3-pip python3-venv git curl wget > /dev/null
            ;;
        *rhel*|*centos*|*fedora*)
            print_status "Using dnf/yum for package installation..."
            local pkg_manager="dnf"
            command -v dnf &> /dev/null || pkg_manager="yum"
            
            sudo $pkg_manager install -y python3 python3-pip git curl wget > /dev/null
            sudo $pkg_manager install -y python3-venv > /dev/null || \
                print_warning "python3-venv not available, will install virtualenv via pip."
            ;;
        *)
            print_error "Unsupported OS family: $os_family"
            exit 1
            ;;
    esac
}

setup_venv() {
    print_header "Setting Up Python Virtual Environment"
    local venv_dir="venv"

    if [ -d "$venv_dir" ]; then
        print_status "Virtual environment already exists: $venv_dir"
        print_status "Activating existing virtual environment..."
        # shellcheck disable=SC1090
        source "$venv_dir/bin/activate"
        return
    fi

    print_status "Creating new virtual environment..."
    if python3 -m venv --help &> /dev/null; then
        python3 -m venv "$venv_dir" > /dev/null
    elif command -v virtualenv &> /dev/null; then
        virtualenv -p python3 "$venv_dir" > /dev/null
    else
        print_status "Installing virtualenv via pip..."
        python3 -m pip install --user virtualenv > /dev/null
        python3 -m virtualenv "$venv_dir" > /dev/null
    fi

    print_status "Activating virtual environment..."
    # shellcheck disable=SC1090
    source "$venv_dir/bin/activate"

    print_status "Upgrading pip..."
    pip install --upgrade pip > /dev/null
}

install_python_packages() {
    print_header "Installing Python Packages"

    if [ -f "requirements.txt" ]; then
        print_status "Installing from requirements.txt..."
        print_status "This will take a while, please be patient."
        pip install -r requirements.txt > /dev/null # Suppress output for cleaner logs
    else
        print_status "Installing Ansible and dependencies..."
        pip install "ansible>=9.0.0" netaddr jmespath kubernetes cryptography > /dev/null
    fi

    print_status "Verifying Ansible installation..."
    ansible --version | head -n1
}

verify_installation() {
    print_header "Verifying Installation"

    command -v ansible &> /dev/null && print_status "✓ Ansible is available" || 
        { print_error "✗ Ansible installation failed"; exit 1; }

    for file in "k3s-deploy.yml" "k8s-install.yml" "hosts.ini"; do
        [ -f "$file" ] && print_status "✓ $file found" || print_warning "! $file not found"
    done
}

show_usage() {
    print_header "Usage Instructions"
    
    echo "1. Update hosts.ini with your server details"
    echo "2. Run: ansible-playbook -i hosts.ini k8s-install.yml"
    echo "3. Or for K3s: ansible-playbook -i hosts.ini k3s-deploy.yml"
    echo ""
    echo "Target specific groups: --limit masters or --limit workers"
    [ -d "venv" ] && echo "Deactivate venv when done: deactivate"
}

main() {
    print_header "Container Deployment Environment Setup"

    os_family=$(detect_os_family)
    print_status "Detected OS family: $os_family"

    echo -e "\nChoose installation method:"
    echo "1) Virtual environment (recommended)"
    echo "2) System-wide installation"
    echo "3) Install system packages only"
    
    read -rp "Enter your choice (1-3): " choice

    install_system_packages "$os_family"

    case "$choice" in
        1)
            print_status "Setting up virtual environment..."
            setup_venv
            install_python_packages
            verify_installation
            show_usage
            print_status "Virtual environment setup complete!"
            ;;
        2)
            print_status "Setting up system-wide installation..."
            cmd="pip3 install --user"
            [ "$(id -u)" -eq 0 ] && cmd="pip install"
            $cmd "ansible>=9.0.0" netaddr jmespath kubernetes cryptography > /dev/null
            hash -r  # Refresh shell's command lookup
            print_warning "Ensure ~/.local/bin is in your PATH if using --user installs."
            verify_installation
            show_usage
            print_status "System-wide installation complete!"
            ;;
        3)
            print_status "System packages installed. Install Python packages manually."
            ;;
        *)
            print_error "Invalid choice. Please run again and select 1, 2, or 3."
            exit 1
            ;;
    esac
}

main "$@"
