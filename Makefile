# Makefile for Kubernetes/K3s Deployment
# Provides convenient shortcuts for common Ansible operations

.PHONY: help install lint check deploy-k3s deploy-k8s deploy-docker ping clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install       - Install Python dependencies and Ansible collections"
	@echo "  lint          - Run ansible-lint on playbooks"
	@echo "  check         - Run syntax check on playbooks"
	@echo "  ping          - Test connectivity to all hosts"
	@echo "  deploy-k3s    - Deploy K3s cluster"
	@echo "  deploy-k8s    - Deploy Kubernetes cluster"
	@echo "  deploy-docker - Install Docker on specified hosts"
	@echo "  clean         - Clean up temporary files"

# Install dependencies
install:
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt
	@echo "Installing Ansible collections..."
	ansible-galaxy collection install -r requirements.yml

# Lint playbooks
lint:
	@echo "Running ansible-lint..."
	ansible-lint k3s-deploy.yml
	ansible-lint k8s-install.yml
	ansible-lint docker-install.yml

# Check syntax
check:
	@echo "Checking playbook syntax..."
	ansible-playbook --syntax-check k3s-deploy.yml
	ansible-playbook --syntax-check k8s-install.yml
	ansible-playbook --syntax-check docker-install.yml

# Test connectivity
ping:
	@echo "Testing connectivity to all hosts..."
	ansible all -i hosts.ini -m ping

# Deploy K3s cluster
deploy-k3s:
	@echo "Deploying K3s cluster..."
	ansible-playbook -i hosts.ini k3s-deploy.yml

# Deploy Kubernetes cluster
deploy-k8s:
	@echo "Deploying Kubernetes cluster..."
	ansible-playbook -i hosts.ini k8s-install.yml

# Install Docker
deploy-docker:
	@echo "Installing Docker..."
	ansible-playbook -i hosts.ini docker-install.yml

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -f ansible.log
	rm -f *.retry
	rm -f k3s-kubeconfig
	rm -f k8s-kubeconfig
	find . -name "*.tmp" -delete