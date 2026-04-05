# DevOps Engineer Home Assignment

## Overview
This project deploys the Docker example voting app with a full CI/CD pipeline,
cloud infrastructure, and GitOps-based delivery.

## AI Tools Used
- **Claude AI** - Used for step by step guidance on Helm charts, Terraform, ArgoCD, Kubernetes setup
- **ChatGPT** - Used for initial project planning and tool installation guidance
- All code has been reviewed and understood by the author.

## Prerequisites
- Docker Desktop
- Git
- kubectl
- kind
- Helm

## Setup Instructions

### Step 1 - Clone Repository
```bash
git clone https://github.com/bharath14111994/devops-assignment.git
cd devops-assignment
```

### Step 2 - Create Kubernetes Cluster
```bash
kind create cluster --name devops-assignment
```

### Step 3 - Deploy with Helm
```bash
cd helm
helm dependency build ./vote
helm dependency build ./result
helm dependency build ./worker
helm dependency build ./redis
helm dependency build ./db
helm install db ./db
helm install redis ./redis
helm install worker ./worker
helm install vote ./vote
helm install result ./result
```

### Step 4 - Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/
```

### Step 5 - Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open https://localhost:8080
Username: admin
Password: (get from kubectl get secret argocd-initial-admin-secret)

## Complete Flow
1. Developer pushes code to GitHub on feature branch
2. GitHub Actions CI pipeline triggers automatically
3. Docker images are built and pushed to Docker Hub
4. PR is created and merged to main
5. ArgoCD detects changes in GitHub and syncs to Kubernetes
6. Application is deployed automatically

## Branching Strategy
- `main` - production branch, protected
- `feature/*` - feature development branches
- Pull Requests required before merging to main
- CI pipeline runs on every push and PR

## Project Structure
devops-assignment/
├── app/                    # Voting application source code
├── helm/                   # Helm charts
│   ├── library/           # Shared library chart
│   ├── vote/              # Vote service chart
│   ├── result/            # Result service chart
│   ├── worker/            # Worker service chart
│   ├── redis/             # Redis chart
│   └── db/                # PostgreSQL chart
├── terraform/             # AWS infrastructure code
├── argocd/                # ArgoCD application manifests
└── .github/workflows/     # GitHub Actions CI pipeline
## Terraform Infrastructure
AWS infrastructure defined using Terraform and validated using terraform validate.
Tested locally using LocalStack (no real AWS account required).
Resources include:
- EKS Cluster with node groups
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- VPC with subnets and security groups

## CI Pipeline
GitHub Actions pipeline includes:
- Build and push Docker images to Docker Hub
- Versioning strategy (1.0.BUILD_NUMBER for main, pr-NUMBER for PRs)
- Helm chart linting
- Terraform validation

## ArgoCD GitOps
- App-of-Apps pattern implemented
- All applications managed via Git
- Automated sync with self-healing enabled