# TheHive Flow with SeaweedFS

Provide S3-compatible object storage to TheHive Flow with [SeaweedFS](https://github.com/seaweedfs/seaweedfs), deployed as a single all-in-one pod in its own namespace.

| Resource | Value |
|----------|-------|
| S3 endpoint | `http://seaweedfs-all-in-one.seaweedfs.svc.cluster.local:8333` |
| Bucket | `thehive-flow` |
| Access key | `thehive-flow` |
| Secret key | Secret `thehive-flow-s3`, key `AWS_SECRET_ACCESS_KEY` (TheHive Flow namespace) |

The endpoint is fully qualified: with the default Codex `kubernetes` backend, TheHive Flow passes it to Jobs running in another namespace.

## Prerequisites

- Kubernetes cluster (>= 1.29.0) with a default storage class
- Helm 3.x
- kubectl

## Deployment

Run the commands from the chart directory (`thehive-charts/thehive-flow`).

### Create the S3 credentials

The same credentials go to SeaweedFS (`seaweedfs-s3-secret.yaml`) and to TheHive Flow (`thehive-flow-s3-secret.yaml`). Change the secret key in both files before any non-test use.

```bash
kubectl create namespace seaweedfs
kubectl apply -f scenarios/seaweedfs/seaweedfs-s3-secret.yaml

kubectl create namespace thehive-flow
kubectl apply -n thehive-flow -f scenarios/seaweedfs/thehive-flow-s3-secret.yaml
```

### Install SeaweedFS

```bash
helm upgrade --install seaweedfs seaweedfs \
  --repo https://seaweedfs.github.io/seaweedfs/helm --version 4.48.0 \
  -n seaweedfs -f scenarios/seaweedfs/seaweedfs-values.yaml --wait
```

A post-install hook creates the `thehive-flow` bucket.

### Verify

```bash
kubectl get -n seaweedfs pods,svc,pvc

kubectl exec -n seaweedfs deploy/seaweedfs-all-in-one -- \
  sh -c 'echo s3.bucket.list | weed shell'
```

The bucket list includes `thehive-flow`.

## Install TheHive Flow

TheHive Flow also needs PostgreSQL: see the [cnpg](../cnpg/) scenario, or the [combined](../combined/) scenario for a full installation.

```bash
helm install thehive-flow . -n thehive-flow -f scenarios/seaweedfs/values.yaml  # plus your PostgreSQL values
```

## Configuration

- **Storage**: `allInOne.data` in `seaweedfs-values.yaml` (10Gi PVC on the default storage class).
- **Scaling**: for more than one replica, use the SeaweedFS chart's distributed mode (master, volume, filer, s3) instead of `allInOne`.
- **Other S3 stores**: TheHive Flow works with any S3-compatible store. Set `blobstore.s3.*` and the `thehive-flow-s3` Secret accordingly; for AWS S3, leave `blobstore.s3.endpoint` empty and set `blobstore.s3.usePathStyle: false`.
