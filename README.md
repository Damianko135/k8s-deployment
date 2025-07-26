# Kubernetes/K3s Deployment with Ansible

This repository contains Ansible playbooks and scripts to deploy Kubernetes clusters on multiple hosts, supporting both traditional Kubernetes and lightweight K3s deployments. Compatible with Ubuntu/Debian, RHEL/CentOS, and Fedora systems.

## 🚀 Quick Start

### 1. Setup Environment

Run the setup script to install dependencies:

```bash
# Make the script executable
chmod +x install.sh

# Run the setup script
./install.sh
```

Choose from:
- **Option 1**: Virtual environment (recommended)
- **Option 2**: System-wide installation
- **Option 3**: System packages only

### 2. Configure Hosts

Edit `hosts.ini` with your server details:

```ini
# For K3s deployment
[k3s_cluster:children]
k3s_masters
k3s_workers

[k3s_masters]
master1 ansible_host=192.168.1.10 ansible_user=ubuntu

[k3s_workers]
worker1 ansible_host=192.168.1.11 ansible_user=ubuntu
worker2 ansible_host=192.168.1.12 ansible_user=ubuntu

# For traditional Kubernetes
[k8s_cluster:children]
k8s_masters
k8s_workers

[k8s_masters]
master1 ansible_host=192.168.1.10 ansible_user=ubuntu

[k8s_workers]
worker1 ansible_host=192.168.1.11 ansible_user=ubuntu
worker2 ansible_host=192.168.1.12 ansible_user=ubuntu
```

### 3. Run Playbook

```bash
# For virtual environment setup, activate it first:
source venv/bin/activate

# Deploy K3s cluster (recommended - lightweight)
ansible-playbook -i hosts.ini k3s-deploy.yml

# OR deploy traditional Kubernetes
ansible-playbook -i hosts.ini k8s-install.yml

# OR install Docker on specified hosts
ansible-playbook -i hosts.ini docker-install.yml

# Target specific groups
ansible-playbook -i hosts.ini k3s-deploy.yml --limit k3s_masters
ansible-playbook -i hosts.ini k3s-deploy.yml --limit k3s_workers
ansible-playbook -i hosts.ini docker-install.yml --limit docker_hosts
```

## 📋 Requirements

### System Requirements
- **Ubuntu/Debian**: 18.04+ or Debian 10+
- **RHEL/CentOS/Fedora**: 7+ or newer (including Oracle Linux)
- **Minimum**: 2GB RAM, 2 CPU cores per node
- **Network**: SSH access between all nodes

### Dependencies
- Python 3.8+
- SSH key-based authentication
- Sudo privileges on all nodes

## 🏗 Deployment Options

### K3s (Recommended)
- **Lightweight**: Minimal resource usage
- **Latest Version**: K3s v1.29.1+k3s2 (Kubernetes v1.29)
- **CNI Options**: Calico (default) or Flannel
- **Features**: Built-in HA, embedded etcd, automatic TLS

### Traditional Kubernetes
- **Full-featured**: Complete Kubernetes distribution
- **Customizable**: Full control over components
- **Production-grade**: Enterprise-ready setup

### Docker Installation
- **Multi-OS Support**: Ubuntu/Debian, RHEL/CentOS/Fedora, SUSE
- **Latest Docker CE**: Community Edition with latest features
- **Docker Compose**: Optional Docker Compose installation
- **User Management**: Automatic user group configuration

## 🔧 Configuration

### Supported Operating Systems
The playbook automatically detects and supports:
- Ubuntu/Debian (using apt)
- RHEL/CentOS/Fedora/Oracle Linux (using yum/dnf)

### K3s Customization
Edit variables in `k3s-deploy.yml`:
```yaml
vars:
  k3s_version: "v1.33.2+k3s1"       # Latest stable
  cni_plugin: "calico"               # calico or flannel
  pod_network_cidr: "192.168.0.0/16" # Calico default
  k3s_cluster_secret: "YourSecretToken"
```

### Traditional Kubernetes Customization
Edit variables in `k8s-install.yml`:
```yaml
vars:
  kubernetes_version: "1.29"
  pod_network_cidr: "10.244.0.0/16"
```

### Docker Customization
Edit variables in `hosts.ini` under `[docker_hosts:vars]`:
```ini
docker_compose_install=true
docker_compose_version=2.24.5
docker_users=['ubuntu', 'admin']
```

## 📁 File Structure

```
├── install.sh              # Environment setup script
├── k3s-deploy.yml          # K3s installation playbook (recommended)
├── k8s-install.yml         # Traditional Kubernetes playbook
├── docker-install.yml      # Docker installation playbook
├── hosts.ini               # Inventory file for target hosts
├── ansible.cfg             # Ansible configuration
├── requirements.txt        # Python dependencies
├── requirements.yml        # Ansible Galaxy requirements
├── Makefile               # Development shortcuts
└── README.md              # This documentation
```

## 🌟 Features

### K3s Deployment
- ✅ **Latest Version**: K3s v1.33.2+k3s1 with Kubernetes v1.33.2
- ✅ **CNI Choice**: Calico (enterprise-grade) or Flannel (lightweight)
- ✅ **High Availability**: Multi-master setup support
- ✅ **Security**: Network policies with Calico, automatic TLS
- ✅ **Lightweight**: Optimized for edge and IoT deployments
- ✅ **Production Ready**: Used in production environments

### Docker Installation
- ✅ **Multi-OS Support**: Ubuntu/Debian, RHEL/CentOS/Fedora, SUSE
- ✅ **Latest Docker CE**: Automatic installation of Docker Community Edition
- ✅ **Docker Compose**: Optional Docker Compose v2 installation
- ✅ **User Management**: Automatic docker group configuration
- ✅ **Service Management**: Automatic service startup and enablement
- ✅ **Verification**: Built-in installation and functionality testing

### Enhanced Install Script
- ✅ **Multi-OS Support**: Auto-detection of package managers
- ✅ **Virtual Environment**: Isolated Python environment
- ✅ **Fallback Support**: Automatic virtualenv installation
- ✅ **Error Handling**: Robust error management

## 🛠 Development

### Install Development Dependencies
```bash
pip install -r requirements.txt
ansible-galaxy install -r requirements.yml
```

### Testing
```bash
# Test connectivity to all hosts
ansible all -i hosts.ini -m ping

# Check Ansible syntax
ansible-playbook --syntax-check k3s-deploy.yml
ansible-playbook --syntax-check k8s-install.yml
ansible-playbook --syntax-check docker-install.yml

# Validate K3s deployment
kubectl get nodes --kubeconfig ./k3s-kubeconfig

# Validate Docker installation
ansible docker_hosts -i hosts.ini -m command -a "docker --version"
ansible docker_hosts -i hosts.ini -m command -a "docker-compose --version"
```

## 🐛 Troubleshooting

### Common Issues

1. **SSH Connection Issues**
   ```bash
   # Test SSH connectivity
   ssh -i ~/.ssh/id_rsa user@host
   ```

2. **Permission Denied**
   - Ensure SSH keys are properly configured
   - Check user has sudo privileges

3. **Package Installation Failures**
   - Verify internet connectivity on target hosts
   - Check repository availability
   - For Oracle Linux: Ensure proper repos are enabled

4. **Virtual Environment Issues**
   ```bash
   # Recreate virtual environment
   rm -rf venv
   ./install.sh
   ```

5. **K3s Specific Issues**
   ```bash
   # Check K3s status
   sudo systemctl status k3s
   
   # View K3s logs
   sudo journalctl -u k3s -f
   
   # Verify cluster status
   k3s kubectl get nodes
   ```

6. **Calico Network Issues**
   ```bash
   # Check Calico pods
   k3s kubectl get pods -n calico-system
   
   # View Calico logs
   k3s kubectl logs -n calico-system -l k8s-app=calico-node
   ```

7. **Docker Specific Issues**
   ```bash
   # Check Docker status
   sudo systemctl status docker
   
   # View Docker logs
   sudo journalctl -u docker -f
   
   # Test Docker functionality
   docker run --rm hello-world
   
   # Check Docker Compose
   docker-compose --version
   
   # Verify user in docker group
   groups $USER
   ```

### Debugging

Enable verbose output:
```bash
ansible-playbook -i hosts.ini k3s-deploy.yml -vvv
ansible-playbook -i hosts.ini docker-install.yml -vvv
```

### Getting K3s Kubeconfig
After successful deployment, the kubeconfig is automatically saved to `./k3s-kubeconfig`:
```bash
# Use the kubeconfig
export KUBECONFIG=./k3s-kubeconfig
kubectl get nodes
```

## 📖 Additional Resources

- [K3s Documentation](https://docs.k3s.io/)
- [Calico Documentation](https://docs.tigera.io/calico/latest)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ansible Kubernetes Collection](https://galaxy.ansible.com/kubernetes/core)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
