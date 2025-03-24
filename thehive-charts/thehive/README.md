# TheHive Helm Chart

[![Chart version 0.2.2](https://img.shields.io/badge/Chart_version-0.2.2-blue.svg?logo=helm)](https://github.com/StrangeBeeCorp/helm-charts/releases/tag/thehive-0.2.2) [![App version 5.4.8-1](https://img.shields.io/badge/App_version-5.4.8--1-blue)](https://docs.strangebee.com/thehive/release-notes/release-notes-5.4/)

The [official Helm Chart](https://github.com/StrangeBeeCorp/helm-charts) of [TheHive](https://strangebee.com/thehive/) for Kubernetes.


## Prerequisites

- Kubernetes `1.23.0` and later
- Helm `3.8.0` and later


## Using the Chart

> [!TIP]
> For more options, check out [helm install](https://helm.sh/docs/helm/helm_install/) documentation and [the customization section](./README.md#customizing-this-chart) of this page

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
- [bitnami/charts cassandra](https://github.com/bitnami/charts/tree/main/bitnami/cassandra) - used as database
- [bitnami/charts elasticsearch](https://github.com/bitnami/charts/tree/main/bitnami/elasticsearch) - used as index
- [minio/minio (community)](https://github.com/minio/minio/tree/master/helm/minio) - used as s3 compatible object storage


## Upgrading a Release

> [!TIP]
> For more options, check out [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) documentation

```bash
# Upgrade the targeted Release with the latest version
helm upgrade [RELEASE_NAME] strangebee/thehive
```


## Customizing this Chart

> [!TIP]
> See [Helm documentation on how to customize a Chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing)

Use the following command to see all available options to tweak this Chart:
```bash
helm show values strangebee/thehive
```

You should also check available options [from this Chart's dependencies](./README.md#dependencies) to customize other services.


## Default configuration and best practices

For convenience, this Helm Chart is provided with all required components out of the box.
While this can be a good fit for a dev environment, it is **highly recommended** to review all dependencies before moving to production.


### Storage considerations

> [!IMPORTANT]
> Regular backups of your PVs are **paramount** to prevent data loss

If not changed, this Chart uses **your default [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)** to create persistent volumes.

You should make sure that the StorageClass you use:
- Is backed up regularly (some tools like [Velero](https://velero.io/) can help automate backups)
- Has a fitting `reclaimPolicy` to reduce the risk of data loss

To configure StorageClasses according to your needs, you should check out relevant CSI drivers for your infrastructure
(such as the [EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) for AWS, the [persistent disk CSI driver](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver) for GCP...).


### ElasticSearch

By default, this Chart will deploy an ElasticSearch cluster made of 2 nodes (both master-eligible and general purposed).

You can check out [the related Helm Chart](./README.md#dependencies) to see configuration options.


### Cassandra

Two Cassandra pods are started by this Chart to store TheHive's data.

You can check out [the related Helm Chart](./README.md#dependencies) to see configuration options.


### Object storage

To support multiple replicas of TheHive, we define an object storage in the configuration and deploy a single instance of minio.

However, we recommend that you use a managed object storage service to guarantee the best performance and resilience of your deployment, such as:
- [AWS s3](https://aws.amazon.com/s3/)
- [GCP Cloud Storage](https://cloud.google.com/storage)

Do note that [network shared filesystem (e.g. NFS)](https://docs.strangebee.com/thehive/installation/deploying-a-cluster/#file-storage) is supported too, but it can be trickier to implement and slower.


### Cortex

No Cortex server is defined in TheHive configuration by default.

There are multiple ways to add Cortex servers to TheHive, among them:
- [Add it from TheHive UI](https://docs.strangebee.com/thehive/administration/cortex/)
- Add Cortex information in the related `values.yaml` object

For the latter, here is an example:
```yaml
cortex:
  enabled: true
  protocol: "http"
  hostnames:
    - "cortex.default.svc" # Assuming cortex is deployed in the "default" namespace
  port: 9001
  api_keys:
    - "<insert_cortex_api_key_here>" # Or even better, use an existing secret using the parameters below
  #k8sSecretName: ""
  #k8sSecretKey: "api-keys"
```
