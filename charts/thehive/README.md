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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| cassandra.clusterName | string | `"TheHive"` | Cassandra cluster name |
| cassandra.dcName | string | `"DC1-TheHive"` | Cassandra datacenter name |
| cassandra.enabled | bool | `true` | Enable Cassandra database |
| cassandra.heapNewSize | string | `"1024M"` | Cassandra heap new size |
| cassandra.maxHeapSize | string | `"1024M"` | Cassandra max heap size |
| cassandra.persistence.enabled | bool | `true` | Enable Cassandra persistence |
| cassandra.persistence.size | string | `"2Gi"` | Cassandra persistent volume size |
| cassandra.persistence.storageClass | string | `"standard"` | Cassandra storageClass |
| cassandra.persistence.volumeMode | string | `"Filesystem"` | Cassandra volume mode (Filesystem or Block)  |
| cassandra.rackName | string | `"Rack1-TheHive"` | Cassandra rack name |
| cassandra.resources.limits.cpu | string | `"1000m"` |  |
| cassandra.resources.limits.memory | string | `"1600Mi"` |  |
| cassandra.resources.requests.cpu | string | `"500m"` |  |
| cassandra.resources.requests.memory | string | `"1600Mi"` |  |
| cassandra.version | string | `"4.1"` |  |
| elasticsearch | object | {} | For more information: https://github.com/elastic/helm-charts/tree/main/elasticsearch |
| elasticsearch.antiAffinity | string | `"soft"` | Permit co-located instances for solitary minikube virtual machines. |
| elasticsearch.createCert | bool | `false` | Set to true in production  |
| elasticsearch.enabled | bool | `true` | Enable Elasticsearch  |
| elasticsearch.esConfig | object | {esConfig: {}} | Disable xpack security |
| elasticsearch.esJavaOpts | string | `"-Xmx128m -Xms128m"` | Shrink default JVM heap. |
| elasticsearch.minimumMasterNodes | int | `1` | Master nodes |
| elasticsearch.replicas | int | `2` | Replicas count |
| elasticsearch.resources | object | `{"limits":{"cpu":"1000m","memory":"512M"},"requests":{"cpu":"100m","memory":"512M"}}` | Allocate smaller chunks of memory per pod. |
| elasticsearch.secret | object | `{"enabled":false}` | Set to true in production |
| elasticsearch.volumeClaimTemplate | object | {} | Request smaller persistent volumes. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"strangebee/thehive"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| minio.affinity | object | `{}` |  |
| minio.auth | object | `{"rootPassword":"minio123","rootUser":"minio"}` | Minio authentification configuration |
| minio.enabled | bool | `true` | Enable Minio |
| minio.endpoint | string | `"http://thehive-minio:9000"` | Minio endpoint |
| minio.image.repository | string | `"minio/minio"` |  |
| minio.image.tag | string | `"RELEASE.2024-01-18T22-51-28Z"` |  |
| minio.nodeSelector | object | `{}` |  |
| minio.storage | object | `{"volumeClaimValue":"2Gi"}` | Minio storage configuration |
| minio.tolerations | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the fullname template |
| serviceAccount.podReader | object | `{"attach":true,"serviceAccountName":""}` | Attach pod reader role to service account |
| serviceAccount.podReader.attach | bool | `true` | Specifies whether a pod reader role should be attached. Required to running thehive in cluster mode |
| serviceAccount.podReader.serviceAccountName | string | `""` | The name of the service account to map pod reader role. |
| thehive.clusterMinNodesCount | int | `0` | TheHive Nodes count |
| thehive.cortex | object | `{"enabled":false,"hostnames":["thehive-cortex"],"keys":""}` | Cortex configuration |
| thehive.cortex.hostnames | list | `["thehive-cortex"]` | Cortex hostnames |
| thehive.cql | object | `{"hostnames":["thehive-cassandra"],"wait":true}` | Cassandra configuration |
| thehive.cql.hostnames | list | `["thehive-cassandra"]` | Cassandra hostnames |
| thehive.cql.wait | bool | `true` | Wait for Cassandra |
| thehive.extraCommand | list | `[]` | Extra entrypoint arguments. See: https://docs.strangebee.com/thehive/setup/installation/docker/#all-options |
| thehive.extraConfig | string | `""` | Custom application.conf file for TheHive |
| thehive.extraEnv | list | `[]` | Extra environment variables |
| thehive.indexBackend | object | `{"hostnames":["elasticsearch-master"],"type":"elasticsearch"}` | Index Backend configuration |
| thehive.indexBackend.hostnames | list | `["elasticsearch-master"]` | Elasticsearch hostnames |
| thehive.indexBackend.type | string | `"elasticsearch"` | Elasticsearch is the only supported backend for now |
| thehive.initContainers | object | `{"enabled":true}` | Init containers will execute nslookup to resolve the hostnames of cassandra and elasticsearch |
| thehive.initContainers.enabled | bool | `true` | Enable init containers |
| thehive.livenessProbe | object | `{"enabled":true}` | Liveness probes |
| thehive.maxUnavailable | int | `1` | PodDisruptionBudget configuration |
| thehive.readinessProbe | object | `{"enabled":true}` | Readiness probes |
| thehive.s3 | object | {} | Object Storage configuration |
| thehive.s3.accessKey | string | `"minio"` | S3 Access key |
| thehive.s3.endpoint | string | `"http://thehive-minio:9000"` | S3 Endpoint |
| thehive.s3.secretKey | string | `"minio123"` | S3 Secret key |
| thehive.s3.usePathAccessStyle | bool | `true` | S3 Access Style |
| thehive.secret | string | `"SuperSecretForKubernetes"` | TheHive Secret  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| volumes | list | `[]` | Additional volumes on the output Deployment definition. |