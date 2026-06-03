# Legacy Application Modernization Lab: eShop Linux Containers via GitOps

This repository contains an end-to-end application modernization project, transforming a legacy/monolithic `.NET` application into a lightweight, secure, and automated cloud-native architecture. It demonstrates a complete DevOps lifecycle encompassing Infrastructure as Code (IaC), containerization, Continuous Integration (CI), and automated Continuous Delivery (CD) leveraging **GitOps** principles.

---

## 🏗️ Architecture & Workflow

This project adopts a modern GitOps workflow designed to bridge local development with scalable cloud infrastructure:

1. **Local Development (WSL 2):** Developers manage application source code and declarative Kubernetes manifests locally using VS Code and Ubuntu on WSL 2.
2. **Continuous Integration (GitHub Actions):** Every push to the `main` branch triggers an automated GitHub Actions pipeline that checks out the code and sets up the required environment.
3. **Containerization & Registry (AWS ECR):** The pipeline builds an optimized .NET 8.0 Linux container image using a multi-stage Dockerfile, authenticates against AWS, and pushes the compiled image to Amazon Elastic Container Registry (ECR) with the `latest` tag.
4. **Continuous Delivery (ArgoCD GitOps):** An ArgoCD controller running inside the Kubernetes cluster constantly monitors this repository. Upon detecting a change or synchronization trigger, it pulls the updated deployment manifest, retrieves the newly baked image from AWS ECR, and performs a zero-downtime *Rolling Update* across the cluster.

---

## 🛠️ Technology Stack

* **Application Framework:** `.NET 8.0` (C#) - Legacy Backoffice web application refactored to seamlessly run on Linux-based container runtimes.
* **Infrastructure as Code (IaC):** `Terraform` - Used to programmatically provision and manage ephemeral AWS infrastructure predictably.
* **Containerization:** `Docker` - Facilitates predictable build layers through optimized multi-stage Dockerfiles.
* **Orchestration:** `Kubernetes (AWS EKS / Local Cluster)` - Serves as the core container orchestrator platform managing application pods, scaling, and networking.
* **CI/CD Automation:** `GitHub Actions` - Automates testing cycles, secure environment variable handshakes, and remote image building.
* **GitOps Engine:** `ArgoCD` - Provides declarative, automated, and self-healing Continuous Delivery to keep the cluster state identical to the Git source of truth.
* **Cloud Infrastructure:** `Amazon Web Services (AWS)` - Utilizes `AWS ECR` (Elastic Container Registry) for image storage and `AWS ELB` (Elastic Load Balancer) for edge ingress routing.

---

## 📁 Repository Structure

```text
├── .github/workflows/
│   └── deploy.yml            # GitHub Actions CI/CD automation pipeline
├── argocd/
│   └── application.yaml      # ArgoCD Application root configuration manifest
├── k8s-manifests/
│   ├── deployment.yaml       # Kubernetes Deployment manifest (targeting AWS ECR image)
│   └── service.yaml          # Kubernetes Service manifest (provisions AWS Load Balancer)
├── src/
│   ├── Controllers/          # Backend application logic
│   ├── Models/               # Application data models
│   ├── Program.cs            # .NET 8.0 main application entry point
│   ├── eShopLinuxApp.csproj  # .NET project dependency and compilation configuration
│   └── Dockerfile            # Optimized multi-stage Docker build specifications
└── terraform/                # Terraform provisioning scripts for AWS infrastructure
```

## 🚀 Lab Execution Guide (Quick Start)
1. Prerequisites
Ensure your local environment has the following components installed and active:

WSL 2 (Ubuntu distribution)

Docker Desktop with local Kubernetes feature enabled (kubectl)

AWS CLI v2 & Terraform CLI

2. Infrastructure Provisioning
Navigate to the terraform directory and initialize the cloud state:

```bash
cd terraform
terraform init
terraform apply
```
Retrieve your temporary AWS Sandbox credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) and map them as encrypted GitHub Repository Secrets.

3. Triggering the CI Pipeline
Push your initial codebase to your remote GitHub repository to kickstart the Docker image pipeline:

```bash
git add .
git commit -m "feat: initial clean commit for app modernization lifecycle"
git branch -M main
git remote add origin https://github.com/tmwaas/eshop-app-modernization.git
git push -u origin main
```
Monitor the Actions tab in your GitHub browser window until you receive a successful green checkmark.

4. Continuous Delivery Sync via ArgoCD
Establish a secure port-forward gateway into your cluster's ArgoCD server management layer:

```bash
kubectl port-forward svc/argocd-server -n argocd 8888:443
```

Navigate to https://localhost:8888 via your host browser, log in, and register the configuration found inside argocd/application.yaml.

Select Sync within the ArgoCD UI dashboard to instruct the cluster to fetch your newly created manifests.

Once the application reporting tree shifts to a Synced & Healthy status, fetch the generated external AWS Load Balancer URL from your service components tab to view the live running modernized application.