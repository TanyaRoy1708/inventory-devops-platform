#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Use HTTPS package sources because outbound access is limited to port 443.
sed -i \
  -e 's|http://[^ ]*archive.ubuntu.com/ubuntu/|https://archive.ubuntu.com/ubuntu/|g' \
  -e 's|http://security.ubuntu.com/ubuntu/|https://security.ubuntu.com/ubuntu/|g' \
  /etc/apt/sources.list.d/ubuntu.sources

apt-get update
apt-get install -y ca-certificates curl git jq unzip less libicu74 openssl

# Use one temporary directory for all downloads and clean it on exit.
bootstrap_dir="$(mktemp -d)"
trap 'rm -rf -- "$bootstrap_dir"' EXIT
cd "$bootstrap_dir"

# AWS CLI v2: use the official system-wide installer.
curl -fsSL https://awscli.amazonaws.com/v2/install.sh -o install-aws.sh
bash install-aws.sh --system

# kubectl: download the pinned version and verify its checksum.
kubectl_url="https://dl.k8s.io/release/v1.36.5/bin/linux/amd64/kubectl"
curl -fsSL "$kubectl_url" -o kubectl
curl -fsSL "$kubectl_url.sha256" -o kubectl.sha256
printf '%s  kubectl\n' "$(cat kubectl.sha256)" | sha256sum --check
install -m 0755 kubectl /usr/local/bin/kubectl

# Helm: its official installer verifies the release checksum.
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 -o install-helm.sh
bash install-helm.sh --version v4.3.2

# Prepare a non-root account and directory for GitHub runner registration.
useradd --create-home --shell /bin/bash runner
install -d -o runner -g runner -m 0755 /opt/actions-runner

aws --version
kubectl version --client
helm version --short
