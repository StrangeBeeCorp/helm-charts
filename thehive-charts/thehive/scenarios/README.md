# TheHive Deployment Scenarios

This directory contains tested deployment scenarios for TheHive Helm chart.

## Available Scenarios

| Scenario | Description | Use Case |
|----------|-------------|----------|
| [standalone](./standalone/) | External Cassandra, Elasticsearch and S3 | Backends operated outside the chart (managed services, dedicated clusters) |
| [k8ssandra-operator](./k8ssandra-operator/) | K8ssandra Operator for Cassandra | Modern, operator-based Cassandra deployment |
| [eck-operator](./eck-operator/) | Elastic Cloud on Kubernetes (ECK) | Operator-based Elasticsearch deployment |
| [combined-operators](./combined-operators/) | K8ssandra + ECK Operators | Full operator-based deployment (Cassandra + Elasticsearch) |
| [seaweedfs](./seaweedfs/) | SeaweedFS object storage | Lightweight S3-compatible replacement for the MinIO subchart |
| [flow](./flow/) | TheHive Flow | Deploy TheHive together with TheHive Flow |
| [migration](./migration/) | Bundled to standalone migration | Move an existing bundled release to external backends |

## Usage Pattern

Each scenario is self-contained. Follow its README for prerequisites, then deploy from the chart directory:

```bash
helm install thehive . -f scenarios/<scenario-name>/values.yaml -n thehive --create-namespace
```

## Scenario: k8ssandra-operator

Use this scenario if you want:

- Operator-based Cassandra deployment
- Automated backups with Medusa
- Multi-datacenter replication
- No dependency on deprecated Bitnami images

To deploy, follow the [scenario documentation](./k8ssandra-operator/README.md).

## Support

For issues or questions:

- **Chart Issues**: <https://github.com/StrangeBeeCorp/helm-charts/issues>
- **TheHive Documentation**: <https://docs.strangebee.com/thehive/>
