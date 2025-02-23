# Flask Hello World Application

Simple Flask application deployment to AWS EKS cluster, using existing Application Load Balancer.

## Deployment Steps

### Prerequisites
- AWS CLI configured with your AWS account
- kubectl configured for EKS cluster

### Build and Deploy

1. Get your AWS account ID and region:
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export AWS_REGION=$(aws configure get region)
```

2. Create ECR repository (if it doesn't exist):
```bash
aws ecr create-repository \
    --repository-name flask-hello-world \
    --region ${AWS_REGION} || true
```

3. Build and push image to ECR:
```bash
# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build and push
docker build -t flask-hello-world .
docker tag flask-hello-world:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/flask-hello-world:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/flask-hello-world:latest
```

4. Deploy to EKS:
```bash
kubectl apply -f k8s-manifest.yaml
```

5. Verify deployment:
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
