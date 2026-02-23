# TheHive with K8ssandra and ECK Operators

Deploy TheHive using both K8ssandra Operator for Cassandra and ECK Operator for Elasticsearch - a fully operator-based deployment.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl

## Deployment

### Requirements

Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io         
helm repo update                                                                          

helm install cert-manager jetstack/cert-manager \                                                     
  --namespace cert-manager \              
  --create-namespace \
  --set installCRDs=true
```

### Install K8ssandra Operator

```bash
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update
helm install k8ssandra-operator k8ssandra/k8ssandra-operator -n k8ssandra-operator --create-namespace
```

Wait for the operator to be ready:

```bash
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=k8ssandra-operator \
  -n k8ssandra-operator --timeout=5m
```

### Deploy Cassandra Cluster

```bash
kubectl apply -f ../k8ssandra-operator/k8ssandra-cluster.yaml
```

Wait for Cassandra to be ready (this may take 2-5 minutes):

```bash
kubectl wait --for=condition=ready pod \
  -l cassandra.datastax.com/cluster=cassandra \
  -n k8ssandra-operator --timeout=10m
```

### Install ECK Operator

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
kubectl apply -f ../eck-operator/elasticsearch.yaml
```

Wait for Elasticsearch to be ready (this may take 2-5 minutes):

```bash
kubectl wait --for=condition=ready pod \
  -l elasticsearch.k8s.elastic.co/cluster-name=elasticsearch \
  -n elastic-system --timeout=10m
```

### Extract Credentials and Create Secrets

Create thehive namespace if it doesn't exist:

```bash
kubectl create namespace thehive --dry-run=client -o yaml | kubectl apply -f -
```

Extract and create Cassandra credentials:

```bash
CASSANDRA_USERNAME=$(kubectl get secret cassandra-superuser \
  -n k8ssandra-operator \
  -o jsonpath='{.data.username}' | base64 -d)

CASSANDRA_PASSWORD=$(kubectl get secret cassandra-superuser \
  -n k8ssandra-operator \
  -o jsonpath='{.data.password}' | base64 -d)

kubectl create secret generic cassandra-credentials \
  -n thehive \
  --from-literal=username="${CASSANDRA_USERNAME}" \
  --from-literal=password="${CASSANDRA_PASSWORD}"
```

Extract and create Elasticsearch credentials:

```bash
ELASTICSEARCH_PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user \
  -n elastic-system \
  -o jsonpath='{.data.elastic}' | base64 -d)

kubectl create secret generic elasticsearch-credentials \
  -n thehive \
  --from-literal=username="elastic" \
  --from-literal=password="${ELASTICSEARCH_PASSWORD}"
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
kubectl get pods -n elastic-system

# Check TheHive logs
kubectl logs -n thehive -l app.kubernetes.io/name=thehive --tail=50

# Access TheHive
kubectl port-forward -n thehive svc/thehive 9000:9000
```

Open <http://localhost:9000>

- Username: `admin@thehive.local`
- Password: `secret`
