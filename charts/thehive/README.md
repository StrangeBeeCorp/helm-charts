# TheHive Chart

![Version: 0.1.5](https://img.shields.io/badge/Version-0.1.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.2](https://img.shields.io/badge/AppVersion-5.2-informational?style=flat-square)

The official Helm chart of TheHive for Kubernetes.

**Homepage:** <https://github.com/StrangeBeeCorp/helm-charts>

## ⚠️ Disclamer: Work in Progress

This chart is currently in a developmental phase and is not ready for production use.
We want to make sure our users are aware that the contents of this repository are under active development

Thank you for your understanding and support as we work towards building something great!

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| StrangeBee |  | <https://strangebee.com/> |

## Source Code

* <https://github.com/StrangeBeeCorp/helm-charts/tree/main/charts/thehive>

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
