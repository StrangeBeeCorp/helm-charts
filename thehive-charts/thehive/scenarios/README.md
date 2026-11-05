# TheHive Deployment Scenarios

This directory contains example deployment scenarios for TheHive Helm chart. Scenarios marked "Kind" in the CI column are installed and tested on every pull request; the others are examples that CI does not cover.

## Available Scenarios

| Scenario | Description | Use Case | CI |
|----------|-------------|----------|----|
| [standalone](./standalone/) | External Cassandra, Elasticsearch and S3 | Backends operated outside the chart (managed services, dedicated clusters) | Kind |
| [k8ssandra-operator](./k8ssandra-operator/) | K8ssandra Operator for Cassandra | Modern, operator-based Cassandra deployment | - |
| [eck-operator](./eck-operator/) | Elastic Cloud on Kubernetes (ECK) | Operator-based Elasticsearch deployment | - |
| [combined-operators](./combined-operators/) | K8ssandra + ECK Operators, SeaweedFS | No bundled subcharts (Cassandra, Elasticsearch and S3 storage) | - |
| [seaweedfs](./seaweedfs/) | SeaweedFS object storage | Lightweight S3-compatible replacement for the MinIO subchart | Kind |
| [flow](./flow/) | TheHive Flow | Deploy TheHive together with TheHive Flow | Kind |
| [migration](./migration/) | Bundled to standalone migration | Move an existing bundled release to external backends | - |

## Usage Pattern

Each scenario is self-contained. Follow its README for prerequisites, then deploy from the root of the repository:

```bash
helm dependency update thehive-charts/thehive
helm install thehive thehive-charts/thehive -f thehive-charts/thehive/scenarios/<scenario-name>/values.yaml -n thehive --create-namespace \
  --set thehive.httpSecret="$(openssl rand -base64 32)"
```

## Support

For issues or questions:

- **Chart Issues**: <https://github.com/StrangeBeeCorp/helm-charts/issues>
- **TheHive Documentation**: <https://docs.strangebee.com/thehive/>
