# TheHive with TheHive Flow

Deploy [TheHive Flow](../../../thehive-flow/) as a subchart of TheHive. With `thehive-flow.enabled=true`, the chart wires both applications:

| Setting | Value |
|---------|-------|
| TheHive Flow URL (`TH_FLOW_URL`) | The TheHive Flow API Service, e.g. `http://thehive-thehive-flow-api:8081` for a release named `thehive`. Override with `thehive.flow.url` |
| JWT signing key | Secret `thehive-flow-jwt`, key `jwt-symmetric-key`, read by both TheHive and TheHive Flow. Created by the chart from `thehive.flow.signingKey`, or generated and kept across upgrades |
| TheHive Flow connector | `scalligraph.modules += "org.thp.thehive.connector.flow.FlowModule"` added to `application.conf`, unless `thehive.configFile` already loads it |
| TheHive URL used by TheHive Flow | `http://thehive:9000`, the TheHive Service for a release named `thehive`. Set `thehive-flow.config.modules.workers.activities.thehive.url` for another release name |

TheHive Flow needs PostgreSQL and S3-compatible storage. This scenario provides them with the TheHive Flow chart scenarios: [cnpg](../../../thehive-flow/scenarios/cnpg/) and [seaweedfs](../../../thehive-flow/scenarios/seaweedfs/). Everything runs in the `thehive` namespace, except the CloudNativePG operator (`cnpg-system`) and SeaweedFS (`seaweedfs`).

## Prerequisites

- Kubernetes cluster (>= 1.29.0, required by TheHive Flow) with a default storage class
- Helm 3.x
- kubectl, openssl

## Deployment

Run the commands from the repository root.

### 1. PostgreSQL

```bash
helm upgrade --install cnpg cloudnative-pg \
  --repo https://cloudnative-pg.github.io/charts --version 0.29.1 \
  -n cnpg-system --create-namespace --wait

kubectl create namespace thehive
kubectl apply -n thehive -f thehive-charts/thehive-flow/scenarios/cnpg/postgres-secrets.yaml
kubectl apply -n thehive -f thehive-charts/thehive-flow/scenarios/cnpg/postgres-cluster.yaml
kubectl wait -n thehive cluster/thehive-flow-postgresql \
  --for=condition=Ready --timeout=5m
kubectl apply -n thehive -f thehive-charts/thehive-flow/scenarios/cnpg/databases.yaml
```

### 2. Object storage

```bash
kubectl create namespace seaweedfs
kubectl apply -f thehive-charts/thehive-flow/scenarios/seaweedfs/seaweedfs-s3-secret.yaml
kubectl apply -n thehive -f thehive-charts/thehive-flow/scenarios/seaweedfs/thehive-flow-s3-secret.yaml

helm upgrade --install seaweedfs seaweedfs \
  --repo https://seaweedfs.github.io/seaweedfs/helm --version 4.48.0 \
  -n seaweedfs -f thehive-charts/thehive-flow/scenarios/seaweedfs/seaweedfs-values.yaml --wait
```

### 3. TheHive API key of TheHive Flow

TheHive Flow calls TheHive with the API key of a TheHive account. The key only exists once TheHive runs: create the Secret with a placeholder now, and set the real key in step 5.

```bash
kubectl create secret generic thehive-flow-thehive -n thehive \
  --from-literal=api-key=placeholder
```

### 4. TheHive and TheHive Flow

Set `thehive-flow.config.api.public.url` in `thehive-charts/thehive/scenarios/flow/values.yaml`, then:

```bash
helm dependency update thehive-charts/thehive
helm install thehive thehive-charts/thehive -n thehive \
  -f thehive-charts/thehive/scenarios/flow/values.yaml \
  --set thehive.httpSecret="$(openssl rand -base64 32)" \
  --wait --timeout 15m
```

On a fresh install, TheHive Flow and the Temporal services may restart once while Temporal initializes its schema and namespace.

### 5. Set the TheHive API key

In TheHive, create the account TheHive Flow uses and generate its API key, then:

```bash
kubectl create secret generic thehive-flow-thehive -n thehive \
  --from-literal=api-key=<TheHive API key> --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout restart -n thehive deployment/thehive-thehive-flow
```

## Verify

```bash
helm test thehive -n thehive --logs
```

The tests check TheHive and TheHive Flow. TheHive reaches TheHive Flow at the URL in its `TH_FLOW_URL` variable:

```bash
kubectl exec -n thehive deploy/thehive -- printenv TH_FLOW_URL
```

## Bring your own JWT signing key

Create the Secret, then point both charts at it:

```bash
kubectl create secret generic my-flow-jwt -n thehive \
  --from-literal=jwt-symmetric-key="$(openssl rand -base64 32)"

helm install thehive thehive-charts/thehive -n thehive \
  -f thehive-charts/thehive/scenarios/flow/values.yaml \
  --set thehive.flow.k8sSecretName=my-flow-jwt \
  --set thehive-flow.secrets.jwtSymmetricKey.existingSecret=my-flow-jwt \
  ...
```

## JWT signing key notes

- **GitOps tools**: the generated key is kept across upgrades with Helm `lookup`. Argo CD, Flux and `helm template` render without `lookup`, so a new key would be generated at every sync. Set `thehive.flow.signingKey` or bring your own Secret instead.
- **Existing Secret**: the chart creates `thehive-flow-jwt` as a Helm hook, which replaces a Secret of the same name. If you create the Secret yourself, also set `thehive.flow.k8sSecretName`.
- **One release per namespace**: the Secret name is fixed by `thehive-flow.secrets.jwtSymmetricKey.existingSecret`. Change it for a second release in the same namespace.
- **Key change**: changing the key does not restart the pods. Restart TheHive and TheHive Flow afterwards:

  ```bash
  kubectl rollout restart -n thehive deployment/thehive deployment/thehive-thehive-flow
  ```

## Uninstall

```bash
helm uninstall thehive -n thehive
helm uninstall seaweedfs -n seaweedfs
kubectl delete -n thehive \
  -f thehive-charts/thehive-flow/scenarios/cnpg/databases.yaml \
  -f thehive-charts/thehive-flow/scenarios/cnpg/postgres-cluster.yaml
helm uninstall cnpg -n cnpg-system
```

The PVCs of Cassandra, Elasticsearch, MinIO, PostgreSQL and SeaweedFS are kept: delete them to remove the data.

The `thehive-flow-jwt` Secret is also kept: the chart creates it before the TheHive Flow database migrations, as a Helm hook, and a new install reuses its key. Delete it to generate a new key:

```bash
kubectl delete secret thehive-flow-jwt -n thehive
```
