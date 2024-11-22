# TheHive Helm Chart

![Chart version 0.1.7](https://img.shields.io/badge/Chart_version-0.1.7-blue.svg?logo=helm) ![App version 5.4.5-1](https://img.shields.io/badge/App_version-5.4.5--1-blue)

> [!CAUTION]
> This chart is under development and is **not production ready**

The [official Helm Chart](https://github.com/StrangeBeeCorp/helm-charts) of [TheHive](https://strangebee.com/thehive/) for Kubernetes.


## Prerequisites

- Kubernetes `1.23.0` and later
- Helm `3.8.0` and later


## Using the Chart

> [!TIP]
> For more options, check out [helm install](https://helm.sh/docs/helm/helm_install/) documentation and [the configuration section](./README.md#configuration) of this page

```bash
# Add StrangeBee Helm Repository
helm repo add strangebee https://strangebeecorp.github.io/helm-charts/

# Update known Helm Repositories
helm repo update

# Create a release of TheHive Helm Chart
helm install [RELEASE_NAME] strangebee/thehive
```


## Dependencies

This Chart relies on the following Helm Charts by default:
- [deprecated] [elastic/elasticsearch](https://github.com/elastic/helm-charts/tree/main/elasticsearch) - used as index

In addition, this Chart deploys additional services for TheHive to work out of the box:
- [cassandra](https://hub.docker.com/_/cassandra) - used as database
- [minio](https://hub.docker.com/r/minio/minio) (configured with [mc](https://hub.docker.com/r/minio/mc)) - used as s3 compatible object storage


## Upgrading a Release

> [!TIP]
> For more options, check out [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) documentation

```bash
# Upgrade the targeted Release with the latest version
helm upgrade [RELEASE_NAME] strangebee/thehive
```


## Configuration

> [!TIP]
> See [Helm documentation on how to customize a Chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing)

Use the following command to see all available options to tweak this Chart:
```bash
helm show values strangebee/thehive
```

You should also check available options [from this Chart's dependencies](./README.md#dependencies) to customize other services.

### Storage considerations

If not changed, this Chart uses **your default [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)** to create persistent volumes.

You should make sure that the StorageClass you use:
- Is backed up regularly
- Has a fitting `reclaimPolicy` to reduce the risk of data loss

To configure StorageClasses according to your needs, you should check out relevant CSI drivers for your infrastructure
(such as the [EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) for AWS, the [persistent disk CSI driver](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver) for GCP...).


### ElasticSearch

By default, this Chart will deploy an ElasticSearch cluster made of 2 nodes (with one master node).

You can check out [the related Helm Chart](./README.md#dependencies) to see configuration options.


### Cassandra

A single Cassandra pod is started by this Chart to store TheHive's data.

We are exposing some parameters in the Chart's values, but we recommend that you use a dedicated Cassandra cluster for a highly available service.


### Object storage

To support multiple replicas of TheHive, we define an object storage in the configuration and deploy a single instance of minio.

However, we recommend that you use a managed object storage service to guarantee the best performance and resilience of your deployment, such as:
- [AWS s3](https://aws.amazon.com/s3/)
- [GCP Cloud Storage](https://cloud.google.com/storage)
