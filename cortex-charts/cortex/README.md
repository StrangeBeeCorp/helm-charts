# Cortex Helm Chart

[![Chart version 0.1.0](https://img.shields.io/badge/Chart_version-0.1.0-blue.svg?logo=helm)](https://github.com/StrangeBeeCorp/helm-charts/releases/tag/cortex-0.1.0) [![App version 3.2.0-1](https://img.shields.io/badge/App_version-3.2.0--1-blue)](https://github.com/TheHive-Project/Cortex/releases)

The [official Helm Chart](https://github.com/StrangeBeeCorp/helm-charts) for [Cortex](https://strangebee.com/cortex/)


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

# Create a release of Cortex Helm Chart
helm install [RELEASE_NAME] strangebee/cortex
```

Do note that at the first start, you have to access Cortex web page in order to update ElasticSearch database.


## Dependencies

This Chart relies on the following Helm Chart by default:
- [bitnami/charts elasticsearch](https://github.com/bitnami/charts/tree/main/bitnami/elasticsearch) - used as index

It also needs a PersistentVolumeClaim with a `ReadWriteMany` access mode, see [the storage consideration section](./README.md#storage-considerations) for details.


## Upgrading a Release

> [!TIP]
> For more options, check out [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) documentation

```bash
# Upgrade the targeted Release with the latest version
helm upgrade [RELEASE_NAME] strangebee/cortex
```


## Customizing this Chart

> [!TIP]
> See [Helm documentation on how to customize a Chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing)

Use the following command to see all available options to tweak this Chart:
```bash
helm show values strangebee/cortex
```

You should also check available options [from this Chart's dependencies](./README.md#dependencies) to customize ElasticSearch.


## Default configuration and best practices

For convenience, this Helm Chart is provided with all required components out of the box.
While this can be a good fit for a dev environment, it is **highly recommended** to review all dependencies before moving to production.


### Storage considerations

> [!CAUTION]
> Cortex REQUIRES a ReadWriteMany PVC shared with running jobs to send inputs and get outputs once completed

If not changed, this Chart uses **your default [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)** to try and create a PersistentVolumeClaim with a `ReadWriteMany` access mode.

You should target a StorageClass defined in your cluster compatible with this access mode. Multiple solutions area available:
- Run a NFS server reachable from your cluster and [create a PV targeting it](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)
- Dedicated storage solutions like [Longhorn](https://longhorn.io/), [Rook](https://rook.io/), etc.
- Some Cloud Provider specific solutions (e.g. [EFS](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) with the [efs-csi-driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver) for AWS)

Also note that Cortex data is stored on ElasticSearch. We strongly advise you to do regular backups to prevent any data loss, especially if you deploy ElasticSearch on your Kubernetes cluster using the [dependency Helm Chart](./README.md#dependencies).


### ElasticSearch

> [!WARNING]
> Cortex only supports ElasticSearch v7 for now

By default, this Chart will deploy an ElasticSearch cluster made of 2 nodes (both master-eligible and general purposed).

You can check out [the related Helm Chart](./README.md#dependencies) to see configuration options.

As a sidenote, it is possible (but **not recommended**) to use the same ElasticSearch instance for TheHive and Cortex, assuming:
- It uses ElasticSearch v7
- It is reachable and configured properly in both TheHive and Cortex pods

However, it creates an interdependency which can create issues during updates and downtimes.


### Configuring Cortex server in TheHive

To add a Cortex server in TheHive, you can [follow this doc](https://docs.strangebee.com/thehive/administration/cortex/).

If both TheHive and Cortex are deployed in the same Kubernetes cluster, you can use Cortex service's DNS as server URL
```bash
# Replace <namespace> by the namespace where Cortex is deployed
http://cortex.<namespace>.svc:9001
```
