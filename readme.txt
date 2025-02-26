EKS Cluster with Multi-Architecture Flask Application Deployment
===========================================================

This project demonstrates a complete deployment of a Flask application on Amazon EKS (Elastic Kubernetes Service) with support for both AMD64 and ARM64 (Graviton) architectures. The deployment is structured in four main steps.

Step 1: Create EKS Cluster and Deploy Game 2048
---------------------------------------------
- Initial EKS cluster setup
- Deployment of Game 2048 application

Step 2: Deploy Flask Application (Non-Graviton)
-------------------------------------------
- Simple Flask "Hello World" application
- Deployment using existing Application Load Balancer
- Configuration:
  * Namespace: flask-app
  * Access Path: /flask
  * Container Port: 5000
  * Service Type: NodePort
  * Replicas: 2
  * Resource Limits:
    - Memory: 256Mi
    - CPU: 200m
- ALB Configuration:
  * Ingress group name: game-2048-group
  * Path configuration:
    - Flask app: /flask
    - Game 2048: / (root path)

Step 3: Create Graviton Node Group
-------------------------------
- Node Group Configuration:
  * Name: graviton-ng
  * CPU Architecture: ARM64 (Graviton)
  * Instance Requirements:
    - vCPUs: 2
    - Memory: 4GiB
  * Number of Nodes: 2
  * OS: Amazon Linux 2 (Latest EKS-optimized AMI)
  * Volume Size: 80GB
- Features:
  * Private networking enabled
  * Auto-scaling (min: 2, max: 4)
  * Node labels:
    - role: graviton
    - cpu-type: arm64

Step 4: Deploy Flask Application (Graviton)
---------------------------------------
Features:
- Multi-architecture Docker image support (amd64 and arm64)
- Deployment targeting AWS Graviton nodes
- Architecture detection in the application
- Shared ALB with game-2048 application

Deployment Process:
1. Set up Docker BuildX for multi-architecture support
2. Configure Graviton node taints
3. Build and deploy multi-architecture image
4. Verify deployment and pod status

Technical Details
---------------
1. Multi-Architecture Support:
   - Uses Docker Buildx for multi-platform builds
   - Builds both amd64 and arm64 variants
   - Multi-stage build for smaller image size

2. Kubernetes Configuration:
   - Node targeting using both nodeSelector and taints/tolerations
   - Shared ALB configuration
   - Resource limits and requests
   - Rolling update strategy

3. Security:
   - Private networking
   - AWS security groups
   - ALB configuration for internet-facing access

Troubleshooting Guide
-------------------
1. Pod Status Verification:
   ```bash
   kubectl get pods -n flask-app -l app.kubernetes.io/name=app-flask -o wide
   kubectl describe pods -n flask-app -l app.kubernetes.io/name=app-flask
   ```

2. Common Issues:
   - CrashLoopBackOff: Check container logs and verify image build
   - Pod Scheduling Issues: Verify node taints and pod tolerations
   - Image Pull Errors: Check ECR authentication and image tags

3. Rollback Procedure:
   ```bash
   kubectl delete -f k8s-manifest.yaml
   kubectl apply -f ../2-step-deploy-flask-app-non-graviton/k8s-manifest.yaml
   ```

Prerequisites
------------
- AWS CLI configured with your AWS account
- kubectl configured for EKS cluster
- Docker with buildx support
- eksctl installed

Environment Variables
-------------------
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export AWS_REGION=$(aws configure get region)
```

Cleanup
-------
1. Remove Graviton deployment:
   ```bash
   kubectl delete -f k8s-manifest.yaml
   ```

2. Remove node taints (optional):
   ```bash
   kubectl taint nodes -l cpu-type=arm64 graviton=true:NoSchedule-
   ```

3. Clean up Docker buildx:
   ```bash
   docker buildx rm multiarch-builder
