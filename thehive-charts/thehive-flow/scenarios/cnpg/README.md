# TheHive Flow with CloudNativePG

Provide PostgreSQL to TheHive Flow and to its bundled Temporal Server with the [CloudNativePG](https://cloudnative-pg.io/) operator.

The resources use the names the chart expects by default:

| Resource | Name |
|----------|------|
| Cluster (read-write Service) | `thehive-flow-postgresql` (`thehive-flow-postgresql-rw`) |
| Roles | `thehive_flow`, `temporal` |
| Databases | `thehive_flow` (owner `thehive_flow`), `temporal` and `temporal_visibility` (owner `temporal`) |
| Password Secrets | `thehive-flow-postgresql-thehive-flow-user`, `thehive-flow-postgresql-temporal-user` |

The Cluster must run in the TheHive Flow namespace: the chart reaches it by its Service name.

## Prerequisites

- Kubernetes cluster (>= 1.29.0) with a default storage class
- Helm 3.x
- kubectl

## Deployment

Run the commands from the chart directory (`thehive-charts/thehive-flow`).

### Install the CloudNativePG operator

```bash
helm upgrade --install cnpg cloudnative-pg \
  --repo https://cloudnative-pg.github.io/charts --version 0.29.1 \
  -n cnpg-system --create-namespace --wait
```

### Create the PostgreSQL cluster

Create the role Secrets first: the Cluster creates the roles from them.

```bash
kubectl create namespace thehive-flow
kubectl apply -n thehive-flow -f scenarios/cnpg/postgres-secrets.yaml
kubectl apply -n thehive-flow -f scenarios/cnpg/postgres-cluster.yaml

kubectl wait -n thehive-flow cluster/thehive-flow-postgresql \
  --for=condition=Ready --timeout=5m
```

### Create the databases

```bash
kubectl apply -n thehive-flow -f scenarios/cnpg/databases.yaml
```

### Verify

```bash
kubectl get -n thehive-flow cluster,database
```

The Cluster reports `Cluster in healthy state` and the three databases `APPLIED: true`. If a database reports `role "..." does not exist`, check the role status:

```bash
kubectl get -n thehive-flow cluster thehive-flow-postgresql \
  -o jsonpath='{.status.managedRolesStatus}'
```

## Install TheHive Flow

TheHive Flow also needs S3-compatible object storage: see the [seaweedfs](../seaweedfs/) scenario, or the [combined](../combined/) scenario for a full installation.

```bash
helm install thehive-flow . -n thehive-flow -f scenarios/cnpg/values.yaml  # plus your object storage values
```

## Configuration

- **High availability**: set `instances: 3` in `postgres-cluster.yaml`.
- **TLS**: CloudNativePG serves TLS, and the chart connects with `postgresql.sslMode: require`.
- **Passwords**: change them in `postgres-secrets.yaml`. CloudNativePG updates the roles when the Secrets change (`cnpg.io/reload` label).
