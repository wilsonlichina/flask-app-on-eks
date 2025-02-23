# EKS Graviton Node Group

This configuration creates a new node group with AWS Graviton instances in the existing EKS cluster.

## Configuration Details

- Node Group Name: graviton-ng
- Instance Type: t4g.medium (AWS Graviton)
- Number of Nodes: 2
- Architecture: arm64
- OS: Amazon Linux 2
- Volume Size: 20GB

## Prerequisites

- eksctl installed
- AWS CLI configured
- kubectl configured for the cluster

## Deployment Steps

1. Generate the node group configuration:
```bash
# Make the script executable
chmod +x generate-config.sh

# Generate nodegroup.yaml with dynamic values
./generate-config.sh
```

2. Create the node group:
```bash
eksctl create nodegroup -f nodegroup.yaml
```

3. Verify the node group creation:
```bash
# Check node group status
eksctl get nodegroup --cluster my-cc-cluster

# Check nodes
kubectl get nodes -l cpu-type=arm64

# Check node details
kubectl describe nodes -l cpu-type=arm64
```

4. Delete the node group (if needed):
```bash
eksctl delete nodegroup --cluster my-cc-cluster --name graviton-ng
```

## Node Group Features

- Uses AWS Graviton processors (ARM architecture)
- Spread across two availability zones
- Private networking enabled
- Auto-scaling configuration (min: 2, max: 4)
- Node labels for targeting deployments:
  - role: graviton
  - cpu-type: arm64

## Dynamic Configuration

The `generate-config.sh` script automatically:
- Gets AWS region from AWS CLI configuration
- Retrieves subnet IDs from the existing EKS cluster
- Generates nodegroup.yaml with the correct values

## Next Steps

After the node group is created, you can deploy applications to the Graviton nodes using node selectors:

```yaml
nodeSelector:
  cpu-type: arm64
