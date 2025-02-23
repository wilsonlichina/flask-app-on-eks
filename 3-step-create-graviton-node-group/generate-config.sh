#!/bin/bash

# Get AWS region from AWS CLI configuration
export AWS_REGION=$(aws configure get region)

# Get cluster name
CLUSTER_NAME="my-cc-cluster"

# Define subnet and security group IDs
SUBNET_IDS="subnet-0200382de3d5401c7 subnet-0308e52a6a78f5251"
SECURITY_GROUP_ID="sg-0048928e5272fe89a"

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
    desiredCapacity: 2
    minSize: 2
    maxSize: 4
    amiFamily: AmazonLinux2
    instanceSelector:
      cpuArchitecture: arm64
      vCPUs: 2
      memory: 4GiB
    volumeSize: 80
    privateNetworking: true
    securityGroups:
      attachIDs: ["${SECURITY_GROUP_ID}"]
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
