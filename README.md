# Flask Hello World Application

Simple Flask application deployment to AWS EKS cluster, using existing Application Load Balancer.

## Deployment Steps

### Prerequisites
- macOS
- Docker Desktop installed and running
- AWS CLI configured with account 595115466597
- kubectl configured for EKS cluster in us-east-1

### Build and Deploy

1. Build and push image to ECR:
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 595115466597.dkr.ecr.us-east-1.amazonaws.com

# Build and push
docker build -t flask-hello-world .
docker tag flask-hello-world:latest 595115466597.dkr.ecr.us-east-1.amazonaws.com/flask-hello-world:latest
docker push 595115466597.dkr.ecr.us-east-1.amazonaws.com/flask-hello-world:latest
```

2. Deploy to EKS:
```bash
kubectl apply -f k8s-manifest.yaml
```

3. Verify deployment:
```bash
# Check Pod status
kubectl get pods -n flask-app -l app.kubernetes.io/name=app-flask

# Check Service status
kubectl get svc -n flask-app service-flask

# Check Ingress status
kubectl get ingress -n flask-app ingress-flask
```

## Application Configuration

- Namespace: flask-app
- Access Path: /flask
- Container Port: 5000
- Service Type: NodePort
- Replicas: 2
- Resource Limits:
  - Memory: 256Mi
  - CPU: 200m

## ALB Configuration

The application shares the ALB with game-2048 using:
- Ingress group name: game-2048-group
- Path configuration:
  - Flask app: /flask
  - Game 2048: / (root path)
- Common annotations:
  - alb.ingress.kubernetes.io/scheme: internet-facing
  - alb.ingress.kubernetes.io/target-type: ip
  - alb.ingress.kubernetes.io/group.name: game-2048-group
