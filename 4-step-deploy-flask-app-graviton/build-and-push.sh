#!/bin/bash

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION=$(aws configure get region)

# ECR repository
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/flask-hello-world"

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Remove existing builder if exists
docker buildx rm multiarch-builder 2>/dev/null || true

# Create a new builder instance
docker buildx create --name multiarch-builder --use

# Build and push multi-architecture image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ${ECR_REPO}:latest \
  --push \
  .

# Clean up
docker buildx rm multiarch-builder
