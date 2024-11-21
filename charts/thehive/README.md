# TheHive Helm Chart

![Chart version 0.1.6](https://img.shields.io/badge/Chart_version-0.1.6-blue.svg?logo=helm) ![App version 5.4.4-1](https://img.shields.io/badge/App_version-5.4.4--1-blue)

> [!CAUTION]
> This chart is under development and is **not production ready**

The [official Helm Chart](https://github.com/StrangeBeeCorp/helm-charts) of [TheHive](https://strangebee.com/thehive/) for Kubernetes.


## Installation

```bash
helm dependency update # Update dependencies - Only if Elasticsearch is enabled
helm install thehive . --values values.yaml # Install the chart with the release name `thehive`
helm upgrade thehive . --values values.yaml # Upgrade the release
```

## Storage configuration

**By default, the chart will use a Persistent Volume Claim with the default StorageClass.**

*Kubernetes documentation about StorageClass : [Kubernetes - StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)*

The default volume mode is Filesystem but TheHive recommends to use Block volume mode for Cassandra.

Block volume mode is available with the following plugins :
- CSI
- FC (Fibre Channel)
- iSCSI
- Local volume
- OpenStack Cinder
- VsphereVolume

More informations on [Kubernetes - Raw Block Volume Support](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#raw-block-volume-support)

The recommendation is to use CSI plugin with a Block volume mode.
- AWS EBS CSI driver : [AWS EBS CSI driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver?tab=readme-ov-file)
- GCP Persistent Disk CSI driver : [GCP Persistent Disk CSI driver](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver)

## Elasticsearch configuration

By default, the chart will install an Elasticsearch cluster with 2 nodes / 1 master.

All informations about Elasticsearch configuration are available on the [Elasticsearch chart documentation](https://github.com/elastic/helm-charts/tree/main/elasticsearch)

## S3 configuration

By default, the chart will use a pre-configured MinIO.
You can also use:
- AWS S3
- GCP Cloud Storage

## Backup

TheHive recommends to stop the application before backup to avoid data corruption.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.elastic.co | elasticsearch | 7.17.3 |
