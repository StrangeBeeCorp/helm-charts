# TheHive with K8ssandra Operator

Deploy TheHive using K8ssandra operator for Cassandra.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl

## Deployment

### Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

Wait for cert-manager to be ready:

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=cert-manager \
  -n cert-manager --timeout=5m
```

### Install k8ssandra-operator

```bash
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update

helm install k8ssandra-operator k8ssandra/k8ssandra-operator \
  -n k8ssandra-operator --create-namespace
```

Wait for the operator pods to be ready:

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=k8ssandra-operator \
  -n k8ssandra-operator --timeout=5m
```

### Deploy Cassandra Cluster

```bash
kubectl apply -f k8ssandra-cluster.yaml
```

Wait for Cassandra to be ready (this may take 2-5 minutes):

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=cassandra \
  -n k8ssandra-operator --timeout=10m
```

### Extract Credentials and Create Secret

K8ssandra automatically creates a superuser secret. Extract the credentials and create a secret for TheHive:

```bash
# Create thehive namespace if it doesn't exist
kubectl create namespace thehive --dry-run=client -o yaml | kubectl apply -f -

# Extract username and password from K8ssandra secret
CASSANDRA_USERNAME=$(kubectl get secret cassandra-superuser \
  -n k8ssandra-operator \
  -o jsonpath='{.data.username}' | base64 -d)

CASSANDRA_PASSWORD=$(kubectl get secret cassandra-superuser \
  -n k8ssandra-operator \
  -o jsonpath='{.data.password}' | base64 -d)

# Create secret in TheHive namespace
kubectl create secret generic cassandra-credentials \
  -n thehive \
  --from-literal=username="${CASSANDRA_USERNAME}" \
  --from-literal=password="${CASSANDRA_PASSWORD}"
```

Verify the secret was created:

```bash
kubectl get secret cassandra-credentials -n thehive
```

### Deploy TheHive

The `values.yaml` file is already configured to use the secret. Deploy TheHive:

```bash
helm install thehive ../../ \
  -f values.yaml \
  -n thehive --create-namespace
```

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n thehive
kubectl get pods -n k8ssandra-operator

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
