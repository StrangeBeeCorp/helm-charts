# TheHive with K8ssandra and ECK Operators

Deploy TheHive using K8ssandra Operator for Cassandra, ECK Operator for Elasticsearch and SeaweedFS for object storage - no bundled subcharts.

## Prerequisites

- Kubernetes cluster (>= 1.23.0)
- Helm 3.x
- kubectl
- jq

## Deployment

Run all commands from the root of the repository.

### Requirements

Install cert-manager

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

### Install K8ssandra Operator

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

### Install ECK Operator

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
helm install elastic-operator elastic/eck-operator \
  --version 3.5.0 \
  -n elastic-system --create-namespace \
  --wait --timeout 5m
```

### Deploy Elasticsearch Cluster

```bash
kubectl apply -f thehive-charts/thehive/scenarios/eck-operator/elasticsearch.yaml
```

Wait for Elasticsearch to be ready (this may take 2-5 minutes). The operator creates the pod a few seconds after the apply, so wait for it to exist first:

```bash
until kubectl get pod -l elasticsearch.k8s.elastic.co/cluster-name=elasticsearch \
  -n elastic-system -o name | grep -q .; do sleep 5; done

kubectl wait --for=condition=ready pod \
  -l elasticsearch.k8s.elastic.co/cluster-name=elasticsearch \
  -n elastic-system --timeout=10m
```

### Install SeaweedFS

Create the namespace and the S3 credentials, then install SeaweedFS:

```bash
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update

kubectl create namespace seaweedfs
kubectl apply -f thehive-charts/thehive/scenarios/seaweedfs/seaweedfs-s3-secret.yaml

helm install seaweedfs seaweedfs/seaweedfs \
  --version 4.48.0 \
  -f thehive-charts/thehive/scenarios/seaweedfs/seaweedfs-values.yaml \
  -n seaweedfs \
  --wait --timeout 5m
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

Extract and create S3 credentials:

```bash
S3_CONFIG=$(kubectl get secret seaweedfs-s3-config \
  -n seaweedfs \
  -o jsonpath='{.data.seaweedfs_s3_config}' | base64 -d)

kubectl create secret generic thehive-s3-credentials \
  -n thehive \
  --from-literal=accessKey="$(jq -r '.identities[0].credentials[0].accessKey' <<<"${S3_CONFIG}")" \
  --from-literal=secretKey="$(jq -r '.identities[0].credentials[0].secretKey' <<<"${S3_CONFIG}")"
```

### Initialize Elasticsearch Index

Create the TheHive index in Elasticsearch:

```bash
ELASTICSEARCH_PASSWORD=$(kubectl get secret elasticsearch-credentials \
  -n thehive \
  -o jsonpath='{.data.password}' | base64 -d)

printf 'user = "elastic:%s"\n' "${ELASTICSEARCH_PASSWORD}" | \
  kubectl run curl-init --image=curlimages/curl:8.17.0 --restart=Never \
  -n elastic-system --rm -i --quiet -- \
  curl -fsS -K - -X PUT http://elasticsearch-es-http:9200/thehive_global
```

The credentials are passed on stdin, so they do not appear in the pod spec.

### Deploy TheHive

Fetch the chart dependencies (the `charts/` directory is not committed):

```bash
helm dependency update thehive-charts/thehive
```

Deploy TheHive with a random HTTP secret:

```bash
helm install thehive thehive-charts/thehive \
  -f thehive-charts/thehive/scenarios/combined-operators/values.yaml \
  -n thehive --create-namespace \
  --set thehive.httpSecret="$(openssl rand -base64 32)"
```

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n thehive
kubectl get pods -n k8ssandra-operator
kubectl get pods -n elastic-system
kubectl get pods -n seaweedfs

# Check TheHive logs
kubectl logs -n thehive -l app.kubernetes.io/name=thehive --tail=50

# Access TheHive
kubectl port-forward -n thehive svc/thehive 9000:9000
```

Open <http://localhost:9000>

- Username: `admin@thehive.local`
- Password: `secret`
