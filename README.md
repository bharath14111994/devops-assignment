# DevOps Engineer Home Assignment

## Overview
This project deploys the Docker example voting app with a full CI/CD pipeline,
cloud infrastructure, and GitOps-based delivery.

## AI Tools Used
- **Claude AI** - Used for step by step guidance on Helm charts, Terraform, ArgoCD, Kubernetes setup, security scanning, monitoring
- **ChatGPT** - Used for initial project planning and tool installation guidance
- All code has been reviewed and understood by the author.

## Prerequisites
- Docker Desktop
- Git
- kubectl
- kind
- Helm
- Terraform

## Setup Instructions

### Step 1 - Clone Repository
git clone https://github.com/bharath14111994/devops-assignment.git
cd devops-assignment

### Step 2 - Create Kubernetes Cluster
kind create cluster --name devops-assignment

### Step 3 - Run Setup Script
bash setup.sh

### Step 4 - Deploy with Helm
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

### Step 5 - Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/

### Step 6 - Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
Open https://localhost:8080
Username: admin
Password: kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

### Step 7 - Access Voting App
kubectl port-forward service/vote 5000:80
kubectl port-forward service/result 5001:80
Open http://localhost:5000 for voting
Open http://localhost:5001 for results

## Complete Flow
1. Developer creates feature branch from main
2. Developer pushes code to GitHub
3. GitHub Actions CI pipeline triggers automatically
4. Docker images are built for vote, result and worker
5. Trivy scans images for CRITICAL vulnerabilities
6. Helm charts are linted and Terraform is validated
7. Images are pushed to Docker Hub with version tag (1.0.BUILD_NUMBER)
8. Helm chart appVersion is updated automatically
9. PR is created and merged to main branch
10. ArgoCD detects changes in GitHub and syncs to Kubernetes
11. Argo Rollouts performs canary deployment (10% traffic first, then 100%)

## Branching Strategy
- main - production branch, protected
- feature/* - feature development branches
- Pull Requests required before merging to main
- CI pipeline runs on every push and PR
- Version bumping only happens on merge to main
- Feature branches build without version bumping

## Project Structure
devops-assignment/
├── .github/workflows/ci.yml              # GitHub Actions CI pipeline
├── app/                                  # Voting application source code
│   ├── vote/                             # Python Flask vote app + Prometheus metrics
│   ├── result/                           # Node.js result app (multi-stage Dockerfile)
│   └── worker/                           # .NET worker service (multi-stage Dockerfile)
├── helm/                                 # Helm charts
│   ├── library/                          # Shared library chart (DRY principle)
│   ├── vote/                             # Vote service chart + ConfigMap
│   ├── result/                           # Result service chart
│   ├── worker/                           # Worker service chart + Argo Rollouts
│   ├── redis/                            # Redis chart
│   └── db/                              # PostgreSQL chart
├── terraform/                            # AWS infrastructure
│   ├── main.tf                           # Provider configuration
│   ├── vpc.tf                            # VPC + Load Balancer
│   ├── eks.tf                            # EKS cluster
│   ├── rds.tf                            # PostgreSQL RDS
│   ├── elasticache.tf                    # Redis ElastiCache
│   ├── variables.tf                      # Input variables
│   └── outputs.tf                        # Output values
├── argocd/                               # ArgoCD manifests
│   ├── app-of-apps.yaml                  # Parent application
│   ├── applicationset.yaml               # CNCF stack ApplicationSet
│   ├── vote-app.yaml                     # Vote application
│   ├── vote-dev-app.yaml                 # Vote dev environment
│   ├── result-app.yaml                   # Result application
│   ├── worker-app.yaml                   # Worker application
│   ├── redis-app.yaml                    # Redis application
│   └── db-app.yaml                       # Database application
├── monitoring/                           # Monitoring stack
│   ├── prometheus-app.yaml               # Prometheus ArgoCD app
│   ├── grafana-app.yaml                  # Grafana ArgoCD app
│   └── grafana-dashboard.yaml            # Custom Grafana dashboard
├── setup.sh                              # Local environment setup script
└── README.md                             # This file

## Terraform Infrastructure
AWS infrastructure defined using Terraform and validated using terraform validate.
Tested locally using LocalStack (no real AWS account required).
Resources include:
- VPC with public subnets, internet gateway, route tables
- EKS Cluster with node groups and IAM roles
- RDS PostgreSQL instance (replaces in-app PostgreSQL)
- ElastiCache Redis cluster (replaces in-app Redis)
- Application Load Balancer for external traffic

## CI Pipeline
GitHub Actions pipeline includes:
- Build and push Docker images to Docker Hub
- Versioning strategy (1.0.BUILD_NUMBER for main, pr-NUMBER for PRs)
- Helm chart appVersion alignment with app version
- Helm chart linting
- Terraform validation
- Trivy security scanning (fails on CRITICAL vulnerabilities)

## ArgoCD GitOps
- App-of-Apps pattern implemented
- ApplicationSet for CNCF stack (Prometheus + Grafana) using List generator
- All applications managed via Git
- Automated sync with self-healing enabled
- Dev environment variable injection via values-dev.yaml

### ApplicationSet Generator Choice
We used the **List generator** because:
- Simple and explicit - each app is clearly defined
- Easy to understand and maintain
- Perfect for a fixed set of known applications (Prometheus + Grafana)

### Alternative Generators
- **Git generator** - discovers apps automatically from Git directory structure
- **Cluster generator** - deploys same app to multiple clusters
- **Matrix generator** - combines multiple generators for complex scenarios

## Helm Charts
- Library chart implements DRY principle (shared deployment + service templates)
- ConfigMaps for web server configuration (OPTION_A, OPTION_B)
- Argo Rollouts canary strategy in vote chart
- Environment-specific values files (values.yaml, values-dev.yaml)

## Security
- Trivy integrated in CI pipeline
- Pipeline fails on CRITICAL severity vulnerabilities
- Docker Hub credentials stored as GitHub Secrets
- Found vulnerability: CVE-2023-45853 in zlib1g (correctly detected)

## Monitoring
- Prometheus collects metrics from all pods
- Grafana visualizes metrics with custom dashboard
- Custom metrics exposed from vote app:
  - vote_count_total - Total votes cast by option
  - http_requests_total - Total HTTP requests by method and endpoint
- Dashboard shows vote counts, HTTP requests, Pod CPU and Memory

## Dockerfile Optimization
- vote app: Multi-stage build (base, dev, final stages)
- result app: Multi-stage build (builder, production stages)
- worker app: Multi-stage build (build, app stages)
- Efficient layer caching with dependency installation before code copy

## Production Architecture
GitHub Repository
       ↓
GitHub Actions CI (Build → Scan → Push)
       ↓
Docker Hub (vote, result, worker images)
       ↓
ArgoCD (GitOps Controller)
       ↓
AWS EKS Cluster
  ├── Vote App (Argo Rollouts Canary)
  ├── Result App
  ├── Worker
  ├── AWS ElastiCache (Redis)
  ├── AWS RDS (PostgreSQL)
  ├── Application Load Balancer
  └── Prometheus + Grafana (Monitoring)

## Production vs Local Differences
- Local uses kind cluster, production uses AWS EKS
- Local uses in-cluster Redis/PostgreSQL, production uses AWS managed services
- Local uses NodePort, production uses Application Load Balancer
- Production would use ACM certificates for HTTPS
- Production would use AWS Secrets Manager for secrets
- Production would have multi-AZ deployment for high availability
- Production would have auto-scaling configured