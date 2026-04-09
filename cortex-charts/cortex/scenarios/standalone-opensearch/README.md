# Cortex Standalone Mode with OpenSearch

## What is this scenario?

This scenario runs Cortex **without** the bundled Elasticsearch subchart, connecting instead to an **externally managed OpenSearch** instance. Cortex is compatible with OpenSearch, though some features like audit logs have limitations.

## Authentication

When OpenSearch has security enabled, set `cortex.index.username` and `cortex.index.password` (or `cortex.index.k8sSecretName` to reference an existing Kubernetes secret). The chart injects these as `CORTEX_ELASTICSEARCH_USERNAME` / `CORTEX_ELASTICSEARCH_PASSWORD` environment variables, which are used by:

- The **init container** to check OpenSearch readiness before Cortex starts.
- The **default `application.conf`** via HOCON substitution (`${?CORTEX_ELASTICSEARCH_USERNAME}` / `${?CORTEX_ELASTICSEARCH_PASSWORD}`) for Cortex's Elasticsearch client.

No manual `configFile` changes are needed for authentication.

> **Note:** HOCON env var substitution requires Cortex image **4.0.1-1 or later**.

See the provided `values.yaml` for an example.

## Usage

Use the provided `values.yaml` as a base and override the hostname or URI to point to your external OpenSearch:

```bash
helm install cortex cortex-charts/cortex \
  --namespace cortex \
  --values cortex-charts/cortex/scenarios/standalone-opensearch/values.yaml \
  --set cortex.httpSecret="$(openssl rand -base64 32)" \
  --set cortex.index.hostnames[0]=my-opensearch.example.com
```

Or use `cortex.index.uri` to pass the full URI directly (takes precedence over hostnames):

```bash
helm install cortex cortex-charts/cortex \
  --namespace cortex \
  --values cortex-charts/cortex/scenarios/standalone-opensearch/values.yaml \
  --set cortex.httpSecret="$(openssl rand -base64 32)" \
  --set cortex.index.uri=http://my-opensearch.example.com:9200
```

## Connecting to OpenSearch outside the cluster

If your OpenSearch runs outside Kubernetes (e.g. Docker Compose, VMs, AWS OpenSearch Service), you can create Kubernetes `Service` and `EndpointSlice` objects to give it a stable DNS name inside the cluster. A template is provided in `k8s-endpoints-template.yaml`.

Replace `${HOST_IP}` with the IP address of your backend host and apply:

```bash
export HOST_IP=10.0.0.50
envsubst < cortex-charts/cortex/scenarios/standalone-opensearch/k8s-endpoints-template.yaml | kubectl apply -n cortex -f -
```

This creates an `opensearch-external` service in the namespace, which matches the default hostname in `values.yaml`. Cortex pods can then reach the external OpenSearch via this service name without any DNS or networking changes.

## Local testing with Docker Compose

A Docker Compose file is provided in `ci/docker-compose-opensearch.yml` to run OpenSearch locally with security enabled (HTTP + auth, HTTPS disabled on REST layer):

```bash
cd cortex-charts/cortex/ci
docker compose -f docker-compose-opensearch.yml up -d --wait --wait-timeout 300
curl -fsSL -u admin:C0rt3xOpenS3arch#2025 'http://localhost:9200/_cluster/health?pretty'
```
