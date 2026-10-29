# TheHive Standalone Mode

## What is Standalone Mode?

Standalone mode runs TheHive **without** bundled subcharts (Cassandra, Elasticsearch, MinIO). Instead, TheHive connects to **externally managed** backend services. This is common in production where databases and search engines are operated as managed services or dedicated clusters.

## Storage Note

When MinIO is disabled and no S3 endpoint is configured, TheHive uses **local filesystem storage**. This is suitable for dev and CI deployments only. For production setups, configure an external S3-compatible storage endpoint.

## Usage

Use the provided `values.yaml` as a base and override the hostnames to point to your external services:

```bash
helm install thehive thehive-charts/thehive \
  --namespace thehive \
  --values thehive-charts/thehive/scenarios/standalone/values.yaml \
  --set thehive.httpSecret="$(openssl rand -base64 32)" \
  --set thehive.database.hostnames[0]=my-cassandra.example.com \
  --set thehive.index.hostnames[0]=my-elasticsearch.example.com
```

Or edit the `values.yaml` file with your Cassandra/Elasticsearch hostnames and install directly:

```bash
helm install thehive thehive-charts/thehive \
  --namespace thehive \
  --values thehive-charts/thehive/scenarios/standalone/values.yaml \
  --set thehive.httpSecret="$(openssl rand -base64 32)"
```

## Connecting to backends outside the cluster

If your backends run outside Kubernetes (e.g. Docker Compose, VMs, managed services), you can create Kubernetes `Service` and `Endpoints` objects to give them stable DNS names inside the cluster. A template is provided in `k8s-endpoints-template.yaml`.

Replace `${HOST_IP}` with the IP address of your backend host and apply:

```bash
export HOST_IP=10.0.0.50
envsubst < thehive-charts/thehive/scenarios/standalone/k8s-endpoints-template.yaml | kubectl apply -n thehive -f -
```

This creates `cassandra-external` and `elasticsearch-external` services in the namespace, which match the default hostnames in `values.yaml`. TheHive pods can then reach the external backends via these service names without any DNS or networking changes.
