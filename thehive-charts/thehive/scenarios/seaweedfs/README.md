# TheHive with SeaweedFS

Deploy TheHive using SeaweedFS for object storage.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl
- jq

## Deployment

Run all commands from the root of the repository.

### Install SeaweedFS

Using Helm (recommended):

```bash
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update
```

Create namespace and S3 credentials:

```bash
kubectl create namespace seaweedfs
kubectl apply -f thehive-charts/thehive/scenarios/seaweedfs/seaweedfs-s3-secret.yaml
```

Install SeaweedFS:

```bash
helm install seaweedfs seaweedfs/seaweedfs \
  --version 4.48.0 \
  -f thehive-charts/thehive/scenarios/seaweedfs/seaweedfs-values.yaml \
  -n seaweedfs \
  --wait --timeout 5m
```

### Verify S3 Service

```bash
kubectl get svc -n seaweedfs seaweedfs-s3
```

### Extract Credentials and Create Secret

SeaweedFS creates an S3 configuration. Extract the credentials and create a secret for TheHive:

```bash
# Create thehive namespace if it doesn't exist
kubectl create namespace thehive --dry-run=client -o yaml | kubectl apply -f -

# Extract S3 credentials from SeaweedFS config
S3_ACCESS_KEY=$(kubectl get secret seaweedfs-s3-config \
  -n seaweedfs \
  -o jsonpath='{.data.seaweedfs_s3_config}' | base64 -d | jq -r '.identities[0].credentials[0].accessKey')

S3_SECRET_KEY=$(kubectl get secret seaweedfs-s3-config \
  -n seaweedfs \
  -o jsonpath='{.data.seaweedfs_s3_config}' | base64 -d | jq -r '.identities[0].credentials[0].secretKey')

# Create secret in TheHive namespace
kubectl create secret generic thehive-s3-credentials \
  -n thehive \
  --from-literal=accessKey="${S3_ACCESS_KEY}" \
  --from-literal=secretKey="${S3_SECRET_KEY}"
```

Verify the secret was created:

```bash
kubectl get secret thehive-s3-credentials -n thehive
```

### Deploy TheHive

Fetch the chart dependencies (the `charts/` directory is not committed):

```bash
helm dependency update thehive-charts/thehive
```

The `values.yaml` file is already configured to use the secret. Deploy TheHive with a random HTTP secret:

```bash
helm install thehive thehive-charts/thehive \
  -f thehive-charts/thehive/scenarios/seaweedfs/values.yaml \
  -n thehive \
  --set thehive.httpSecret="$(openssl rand -base64 32)"
```

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n thehive
kubectl get pods -n seaweedfs

# Wait for TheHive pod to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=thehive \
  -n thehive --timeout=10m

# Check TheHive logs
kubectl logs -n thehive -l app.kubernetes.io/name=thehive --tail=50

# Access TheHive
kubectl port-forward -n thehive svc/thehive 9000:9000
```

Open <http://localhost:9000>

- Username: `admin@thehive.local`
- Password: `secret`
