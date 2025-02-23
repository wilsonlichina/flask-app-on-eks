#!/bin/bash

# Get AWS region from AWS CLI configuration
export AWS_REGION=$(aws configure get region)

# Get cluster name
CLUSTER_NAME="my-cc-cluster"

# Get private subnet IDs from the cluster
SUBNET_IDS=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query 'cluster.resourcesVpcConfig.subnetIds' --output text)

# Convert space-separated subnet IDs to yaml array format
SUBNET_YAML=""
for subnet in ${SUBNET_IDS}; do
    SUBNET_YAML="$SUBNET_YAML      - $subnet\n"
done

# Create nodegroup configuration with dynamic values
cat > nodegroup.yaml << EOF
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER_NAME}
  region: ${AWS_REGION}

managedNodeGroups:
  - name: graviton-ng
    instanceType: t4g.medium
    desiredCapacity: 2
    minSize: 2
    maxSize: 4
    ami: auto
    amiFamily: AmazonLinux2
    instanceSelector:
      cpuArchitecture: arm64
    volumeSize: 80
    privateNetworking: true
    securityGroups:
      attachIDs: ["sg-0048928e5272fe89a"]
    tags:
      k8s.io/cluster-autoscaler/enabled: "true"
      k8s.io/cluster-autoscaler/${CLUSTER_NAME}: "owned"
    labels:
      role: graviton
      cpu-type: arm64
    subnets:
$(echo -e "$SUBNET_YAML")
EOF

echo "Generated nodegroup.yaml with dynamic configuration"
