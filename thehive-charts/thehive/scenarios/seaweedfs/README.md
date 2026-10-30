# TheHive with SeaweedFS

Deploy TheHive using SeaweedFS for object storage.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl

## Deployment

### Install SeaweedFS

Using Helm (recommended):

```bash
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update
```

Create namespace and S3 credentials:

```bash
kubectl create namespace seaweedfs
kubectl apply -f seaweedfs-s3-secret.yaml
```

Install SeaweedFS:

```bash
helm install seaweedfs seaweedfs/seaweedfs \
  -f seaweedfs-values.yaml \
  -n seaweedfs
```

Wait for SeaweedFS to be ready:

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=seaweedfs \
  -n seaweedfs --timeout=5m
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

The `values.yaml` file is already configured to use the secret. Deploy TheHive:

```bash
helm install thehive ../../ \
  -f values.yaml \
  -n thehive
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
