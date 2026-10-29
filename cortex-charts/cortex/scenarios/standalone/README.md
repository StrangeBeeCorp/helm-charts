# Cortex Standalone Mode

## What is Standalone Mode?

Standalone mode runs Cortex **without** the bundled Elasticsearch subchart. Instead, Cortex connects to an **externally managed** Elasticsearch instance. This is common in production where Elasticsearch is operated as a managed service or dedicated cluster.

## Usage

Use the provided `values.yaml` as a base and override the hostname to point to your external Elasticsearch:

```bash
helm install cortex cortex-charts/cortex \
  --namespace cortex \
  --values cortex-charts/cortex/scenarios/standalone/values.yaml \
  --set cortex.httpSecret="$(openssl rand -base64 32)" \
  --set cortex.index.hostnames[0]=my-elasticsearch.example.com
```

Or edit the `values.yaml` file with your Elasticsearch hostname and install directly:

```bash
helm install cortex cortex-charts/cortex \
  --namespace cortex \
  --values cortex-charts/cortex/scenarios/standalone/values.yaml \
  --set cortex.httpSecret="$(openssl rand -base64 32)"
```

## Connecting to backends outside the cluster

If your Elasticsearch runs outside Kubernetes (e.g. Docker Compose, VMs, managed services), you can create Kubernetes `Service` and `EndpointSlice` objects to give it a stable DNS name inside the cluster. A template is provided in `k8s-endpoints-template.yaml`.

Replace `${HOST_IP}` with the IP address of your backend host and apply:

```bash
export HOST_IP=10.0.0.50
envsubst < cortex-charts/cortex/scenarios/standalone/k8s-endpoints-template.yaml | kubectl apply -n cortex -f -
```

This creates an `elasticsearch-external` service in the namespace, which matches the default hostname in `values.yaml`. Cortex pods can then reach the external Elasticsearch via this service name without any DNS or networking changes.
