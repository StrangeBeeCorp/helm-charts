# TheHive Flow Deployment Scenarios

TheHive Flow needs two external services: a PostgreSQL database and an S3-compatible object store. These scenarios show how to provide them in Kubernetes.

## Available Scenarios

| Scenario | Description | Provides |
|----------|-------------|----------|
| [cnpg](./cnpg/) | [CloudNativePG](https://cloudnative-pg.io/) operator | PostgreSQL for TheHive Flow and the bundled Temporal Server |
| [seaweedfs](./seaweedfs/) | [SeaweedFS](https://github.com/seaweedfs/seaweedfs) | S3-compatible object storage |
| [combined](./combined/) | CloudNativePG + SeaweedFS | Full installation of TheHive Flow |

## Usage Pattern

Run the commands from the chart directory (`thehive-charts/thehive-flow`). Each scenario provides a `values.yaml` to pass to `helm install`; the `combined` scenario layers them:

```bash
helm install thehive-flow . -n thehive-flow \
  -f scenarios/cnpg/values.yaml \
  -f scenarios/seaweedfs/values.yaml \
  -f scenarios/combined/values.yaml
```

To deploy everything, follow the [combined scenario](./combined/README.md).

The scenarios use single replicas and demo credentials (`ChangeThis...`): they are meant for testing. Change the credentials and size the services before any other use.

## Support

- **Chart Issues**: <https://github.com/StrangeBeeCorp/helm-charts/issues>
- **TheHive Documentation**: <https://docs.strangebee.com/thehive/>
