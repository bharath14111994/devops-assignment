#!/bin/bash
set -e

echo "Setting up local DevOps environment..."

# Create kind cluster
echo "Creating kind cluster..."
kind create cluster --name devops-assignment

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Deploy App-of-Apps
echo "Deploying App-of-Apps..."
kubectl apply -f argocd/

echo "Setup complete!"
echo "Access ArgoCD at https://localhost:8080"
echo "Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"