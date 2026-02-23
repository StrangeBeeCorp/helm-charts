# TheHive with ECK Operator

Deploy TheHive using Elastic Cloud on Kubernetes (ECK) operator for Elasticsearch.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl

## Deployment

### Install ECK Operator

Using Helm (recommended):

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace
```

Wait for the operator to be ready:

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=elastic-operator \
  -n elastic-system --timeout=5m
```

### Deploy Elasticsearch Cluster

```bash
kubectl apply -f elasticsearch.yaml
```

Wait for Elasticsearch to be ready (this may take 2-5 minutes):

```bash
kubectl wait --for=condition=ready pod \
  -l elasticsearch.k8s.elastic.co/cluster-name=elasticsearch \
  -n elastic-system --timeout=10m
```

### Extract Credentials and Create Secret

ECK automatically creates a user secret. Extract the credentials and create a secret for TheHive:

```bash
# Create thehive namespace if it doesn't exist
kubectl create namespace thehive --dry-run=client -o yaml | kubectl apply -f -

# Extract password from ECK secret (username is always 'elastic')
ELASTICSEARCH_PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user \
  -n elastic-system \
  -o jsonpath='{.data.elastic}' | base64 -d)

# Create secret in TheHive namespace
kubectl create secret generic elasticsearch-credentials \
  -n thehive \
  --from-literal=username="elastic" \
  --from-literal=password="${ELASTICSEARCH_PASSWORD}"
```

Verify the secret was created:

```bash
kubectl get secret elasticsearch-credentials -n thehive
```

### Initialize Elasticsearch Index

Create the TheHive index in Elasticsearch:

```bash
ELASTICSEARCH_PASSWORD=$(kubectl get secret elasticsearch-credentials \
  -n thehive \
  -o jsonpath='{.data.password}' | base64 -d)

kubectl run curl-init --image=curlimages/curl:8.17.0 --restart=Never \
  -n elastic-system --rm -i --quiet -- \
  sh -c "curl -X PUT -u 'elastic:${ELASTICSEARCH_PASSWORD}' \
  http://elasticsearch-es-http:9200/thehive_global"
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
kubectl get pods -n elastic-system

# Check TheHive logs
kubectl logs -n thehive -l app.kubernetes.io/name=thehive --tail=50

# Access TheHive
kubectl port-forward -n thehive svc/thehive 9000:9000
```

Open <http://localhost:9000>

- Username: `admin@thehive.local`
- Password: `secret`
