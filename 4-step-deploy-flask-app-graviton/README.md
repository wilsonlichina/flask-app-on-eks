# Flask Application - Multi-Architecture Deployment

This directory contains a Flask application configured for multi-architecture deployment (amd64 and arm64) with specific targeting of AWS Graviton nodes.

## Features

- Multi-architecture Docker image support (amd64 and arm64)
- Deployment targeting AWS Graviton nodes using taints and tolerations
- Architecture detection in the application
- Shared ALB with game-2048 application

## Prerequisites

- Docker with buildx support
- AWS CLI configured
- kubectl configured for EKS cluster
- Existing Graviton node group (created in step 3)

## Set up Docker BuildX

1. Check if buildx is available:
```bash
docker buildx version
```

2. Create a new builder instance:
```bash
# Create a new builder
docker buildx create --name multiarch-builder

# Switch to the new builder
docker buildx use multiarch-builder

# Inspect available platforms
docker buildx inspect --bootstrap
```

3. Verify multi-platform support:
```bash
# Should show linux/amd64,linux/arm64
docker buildx inspect multiarch-builder | grep Platforms
```

## Configure Graviton Node Taints

1. Verify Graviton nodes:
```bash
# List nodes with labels
kubectl get nodes --show-labels | grep cpu-type=arm64
```

2. Add taints to Graviton nodes:
```bash
# Add taint to all Graviton nodes
kubectl taint nodes -l cpu-type=arm64 graviton=true:NoSchedule

# Verify taints
kubectl get nodes -l cpu-type=arm64 -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## Build and Deploy

1. Make the build script executable:
```bash
chmod +x build-and-push.sh
```

2. Build and push multi-architecture image:
```bash
./build-and-push.sh
```

3. Seamless Deployment to EKS:
```bash
# Get AWS account ID and region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export AWS_REGION=$(aws configure get region)

# Deploy to Graviton nodes
envsubst < k8s-manifest.yaml | kubectl apply -f -

# Perform rolling restart of the deployment
kubectl rollout restart deployment deployment-flask -n flask-app

# Watch the rollout status
kubectl rollout status deployment deployment-flask -n flask-app

# Verify pods are running on Graviton nodes
kubectl get pods -n flask-app -l app.kubernetes.io/name=app-flask -o wide
```

4. Verify deployment:
```bash
# Check pods are on Graviton nodes
kubectl get pods -n flask-app -l app.kubernetes.io/name=app-flask -o wide

# Check service and ingress
kubectl get svc,ing -n flask-app

# Check pod logs
kubectl logs -n flask-app -l app.kubernetes.io/name=app-flask
```

## Architecture Details

### Multi-Architecture Docker Build
- Uses Docker Buildx for multi-platform builds
- Builds both amd64 and arm64 variants in one command
- Uses multi-stage build for smaller image size

### Kubernetes Deployment
- Uses both nodeSelector and taints/tolerations for Graviton targeting:
  ```yaml
  nodeSelector:
    cpu-type: arm64
  tolerations:
  - key: "graviton"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  ```
- Shares ALB with game-2048 using ingress group
- Exposes application at /flask path

### Node Affinity and Taints
- Graviton nodes are tainted with `graviton=true:NoSchedule`
- Only pods with matching tolerations can be scheduled
- Provides stronger isolation than nodeSelector alone
- Ensures non-Graviton workloads don't accidentally schedule on Graviton nodes

### Application
- Displays running architecture using platform.machine()
- Exposes /flask endpoint only
- Uses Gunicorn as the production WSGI server

## Verification

After deployment, you can verify:
1. Pods are scheduled on Graviton nodes:
```bash
kubectl get pods -n flask-app -o wide | grep arm64
```
2. Access the application through ALB at /flask path
3. Response will show: "Hello, World from EKS Flask App running on aarch64!"
   (aarch64 indicates ARM64 architecture)

## Rollback (if needed)

To rollback to non-graviton deployment:
```bash
# Remove graviton deployment
kubectl delete -f k8s-manifest.yaml

# Apply original deployment
kubectl apply -f ../2-step-deploy-flask-app-non-graviton/k8s-manifest.yaml

# Wait for rollout to complete
kubectl rollout status deployment deployment-flask -n flask-app
```

## Cleanup

To remove the graviton deployment:
```bash
kubectl delete -f k8s-manifest.yaml

# Optional: Remove node taints if no longer needed
kubectl taint nodes -l cpu-type=arm64 graviton=true:NoSchedule-
