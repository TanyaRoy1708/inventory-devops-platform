#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Install prerequisites.
apt-get update
apt-get install -y ca-certificates curl git jq unzip less libicu74 openssl

cd /tmp

# Install AWS CLI system-wide.
curl -fsSL https://awscli.amazonaws.com/v2/install.sh -o install-aws.sh
bash install-aws.sh --system

# Install kubectl and verify its checksum.
curl -fsSL https://dl.k8s.io/release/v1.36.5/bin/linux/amd64/kubectl -o kubectl
curl -fsSL https://dl.k8s.io/release/v1.36.5/bin/linux/amd64/kubectl.sha256 -o kubectl.sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm.
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 -o install-helm.sh
bash install-helm.sh --version v4.3.2

# Prepare the GitHub runner account and directory.
useradd --create-home --shell /bin/bash runner
install -d -o runner -g runner /opt/actions-runner

# Verify installed tools.
aws --version
kubectl version --client
helm version --short