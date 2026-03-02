# TheHive Deployment Scenarios

This directory contains tested deployment scenarios for TheHive Helm chart.

## Available Scenarios

| Scenario | Description | Use Case |
|----------|-------------|----------|
| [k8ssandra-operator](./k8ssandra-operator/) | K8ssandra Operator for Cassandra | Modern, operator-based Cassandra deployment |
| [eck-operator](./eck-operator/) | Elastic Cloud on Kubernetes (ECK) | Operator-based Elasticsearch deployment |
| [combined-operators](./combined-operators/) | K8ssandra + ECK Operators | Full operator-based deployment (Cassandra + Elasticsearch) |

## Usage Pattern

Each scenario is self-contained and can be deployed using:

```bash
helm install thehive ../ -f scenarios/<scenario-name>/values.yaml -n thehive --create-namespace
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
