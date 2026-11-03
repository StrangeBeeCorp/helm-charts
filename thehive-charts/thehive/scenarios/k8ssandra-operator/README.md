# TheHive with K8ssandra Operator

Deploy TheHive using K8ssandra operator for Cassandra.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl

## Deployment

Run all commands from the root of the repository.

### Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --version v1.21.3 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --wait --timeout 5m
```

### Install k8ssandra-operator

```bash
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update

helm install k8ssandra-operator k8ssandra/k8ssandra-operator \
  --version 1.34.0 \
  -n k8ssandra-operator --create-namespace \
  --wait --timeout 5m
```

### Deploy Cassandra Cluster

```bash
kubectl apply -f thehive-charts/thehive/scenarios/k8ssandra-operator/k8ssandra-cluster.yaml
```

Wait for Cassandra to be ready (this may take 2-5 minutes). The operator creates the pod a few seconds after the apply, so wait for it to exist first:

```bash
until kubectl get pod -l cassandra.datastax.com/cluster=cassandra \
  -n k8ssandra-operator -o name | grep -q .; do sleep 5; done

kubectl wait --for=condition=ready pod \
  -l cassandra.datastax.com/cluster=cassandra \
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

Fetch the chart dependencies (the `charts/` directory is not committed):

```bash
helm dependency update thehive-charts/thehive
```

The `values.yaml` file is already configured to use the secret. Deploy TheHive with a random HTTP secret:

```bash
helm install thehive thehive-charts/thehive \
  -f thehive-charts/thehive/scenarios/k8ssandra-operator/values.yaml \
  -n thehive --create-namespace \
  --set thehive.httpSecret="$(openssl rand -base64 32)"
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
