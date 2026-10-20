# TheHive Flow with CloudNativePG and SeaweedFS

Full installation of TheHive Flow: PostgreSQL from the [cnpg](../cnpg/) scenario, S3 object storage from the [seaweedfs](../seaweedfs/) scenario, and the bundled Temporal Server.

| Namespace | Content |
|-----------|---------|
| `cnpg-system` | CloudNativePG operator |
| `seaweedfs` | SeaweedFS |
| `thehive-flow` | TheHive Flow, Temporal Server, PostgreSQL cluster |

## Prerequisites

- Kubernetes cluster (>= 1.29.0) with a default storage class
- Helm 3.x
- kubectl, openssl

## Deployment

Run the commands from the chart directory (`thehive-charts/thehive-flow`).

### 1. PostgreSQL

```bash
helm upgrade --install cnpg cloudnative-pg \
  --repo https://cloudnative-pg.github.io/charts --version 0.29.1 \
  -n cnpg-system --create-namespace --wait

kubectl create namespace thehive-flow
kubectl apply -n thehive-flow -f scenarios/cnpg/postgres-secrets.yaml
kubectl apply -n thehive-flow -f scenarios/cnpg/postgres-cluster.yaml
kubectl wait -n thehive-flow cluster/thehive-flow-postgresql \
  --for=condition=Ready --timeout=5m
kubectl apply -n thehive-flow -f scenarios/cnpg/databases.yaml
```

### 2. Object storage

```bash
kubectl create namespace seaweedfs
kubectl apply -f scenarios/seaweedfs/seaweedfs-s3-secret.yaml
kubectl apply -n thehive-flow -f scenarios/seaweedfs/thehive-flow-s3-secret.yaml

helm upgrade --install seaweedfs seaweedfs \
  --repo https://seaweedfs.github.io/seaweedfs/helm --version 4.48.0 \
  -n seaweedfs -f scenarios/seaweedfs/seaweedfs-values.yaml --wait
```

### 3. TheHive Flow secrets

The JWT signing key is shared with TheHive (at least 32 bytes). The TheHive API key is the key of the TheHive account TheHive Flow uses.

```bash
kubectl create secret generic thehive-flow-jwt -n thehive-flow \
  --from-literal=jwt-symmetric-key="$(openssl rand -base64 32)"

kubectl create secret generic thehive-flow-thehive -n thehive-flow \
  --from-literal=api-key=<TheHive API key>
```

### 4. TheHive Flow

Set `config.api.public.url` and the TheHive URL in `combined/values.yaml`, then:

```bash
helm dependency update
helm install thehive-flow . -n thehive-flow \
  -f scenarios/cnpg/values.yaml \
  -f scenarios/seaweedfs/values.yaml \
  -f scenarios/combined/values.yaml \
  --wait --timeout 10m
```

On a fresh install, TheHive Flow and the Temporal services may restart once while Temporal initializes its schema and namespace.

## Verify

```bash
helm test thehive-flow -n thehive-flow --logs

POD=$(kubectl get pods -n thehive-flow \
  -l app.kubernetes.io/name=thehive-flow,app.kubernetes.io/component=thehive-flow \
  -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/thehive-flow/pods/${POD}:9090/proxy/readyz"
```

`readyz` returns `{"status":"ok","checks":{"db":"ok","modules":"ok","temporal":"ok"}}`.

## Connect TheHive

Enable the TheHive Flow integration in the TheHive chart (`thehive.flow.*`): set `url` to `http://thehive-flow-api.thehive-flow.svc.cluster.local:8081` and use the same JWT signing key.

## Uninstall

```bash
helm uninstall thehive-flow -n thehive-flow
helm uninstall seaweedfs -n seaweedfs
kubectl delete -n thehive-flow -f scenarios/cnpg/databases.yaml -f scenarios/cnpg/postgres-cluster.yaml
helm uninstall cnpg -n cnpg-system
```

The PVCs of PostgreSQL and SeaweedFS are kept: delete them to remove the data.
