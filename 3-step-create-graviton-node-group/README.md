# EKS Graviton Node Group

This configuration creates a new node group with AWS Graviton instances in the existing EKS cluster.

## Configuration Details

- Node Group Name: graviton-ng
- Instance Requirements:
  - CPU Architecture: ARM64 (Graviton)
  - vCPUs: 2
  - Memory: 4GiB
- Number of Nodes: 2
- OS: Amazon Linux 2
- Volume Size: 80GB
- Security Group: Using existing cluster security group (sg-0048928e5272fe89a)

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

- Uses AWS Graviton processors (ARM64 architecture)
- Private networking enabled
- Auto-scaling configuration (min: 2, max: 4)
- 80GB EBS volume per node
- Using existing cluster security group
- Node labels for targeting deployments:
  - role: graviton
  - cpu-type: arm64

## Dynamic Configuration

The `generate-config.sh` script automatically:
- Gets AWS region from AWS CLI configuration
- Retrieves subnet IDs from the existing EKS cluster
- Generates nodegroup.yaml with the correct values
- Configures security group attachment

## Instance Selection

The node group uses instanceSelector to automatically choose appropriate Graviton instances:
```yaml
instanceSelector:
  cpuArchitecture: arm64
  vCPUs: 2
  memory: 4GiB
```

This configuration will select the most cost-effective Graviton instance that meets these requirements.

## Next Steps

After the node group is created, you can deploy applications to the Graviton nodes using node selectors:

```yaml
nodeSelector:
  cpu-type: arm64
