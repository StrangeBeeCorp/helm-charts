# thehive

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.2](https://img.shields.io/badge/AppVersion-5.2-informational?style=flat-square)

TheHive official Helm chart for Kubernetes

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| TheHive Project |  | <https://thehive-project.org/> |

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
| elasticsearch | object | `{"antiAffinity":"soft","createCert":false,"enabled":true,"esConfig":{"elasticsearch.yml":"xpack.security.enabled: false\nxpack.security.transport.ssl.enabled: false\nxpack.security.http.ssl.enabled: false\n"},"esJavaOpts":"-Xmx128m -Xms128m","minimumMasterNodes":1,"replicas":2,"resources":{"limits":{"cpu":"1000m","memory":"512M"},"requests":{"cpu":"100m","memory":"512M"}},"secret":{"enabled":false},"volumeClaimTemplate":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"500M"}},"storageClassName":"standard"}}` | For more information: https://github.com/elastic/helm-charts/tree/main/elasticsearch |
| elasticsearch.antiAffinity | string | `"soft"` | Permit co-located instances for solitary minikube virtual machines. |
| elasticsearch.createCert | bool | `false` | Set to true in production  |
| elasticsearch.enabled | bool | `true` | Enable Elasticsearch  |
| elasticsearch.esConfig | object | `{"elasticsearch.yml":"xpack.security.enabled: false\nxpack.security.transport.ssl.enabled: false\nxpack.security.http.ssl.enabled: false\n"}` | Disable xpack security |
| elasticsearch.esJavaOpts | string | `"-Xmx128m -Xms128m"` | Shrink default JVM heap. |
| elasticsearch.minimumMasterNodes | int | `1` | Master nodes |
| elasticsearch.replicas | int | `2` | Replicas count |
| elasticsearch.resources | object | `{"limits":{"cpu":"1000m","memory":"512M"},"requests":{"cpu":"100m","memory":"512M"}}` | Allocate smaller chunks of memory per pod. |
| elasticsearch.secret | object | `{"enabled":false}` | Set to true in production |
| elasticsearch.volumeClaimTemplate | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"500M"}},"storageClassName":"standard"}` | Request smaller persistent volumes. |
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
| thehive.clusterMinNodesCount | int | `0` |  |
| thehive.cortex | object | `{"enabled":false,"hostnames":["thehive-cortex"],"keys":""}` | Cortex configuration |
| thehive.cql | object | `{"hostnames":["thehive-cassandra"],"wait":true}` | Cassandra configuration |
| thehive.extraCommand | list | `[]` | Extra entrypoint arguments. See: https://docs.strangebee.com/thehive/setup/installation/docker/#all-options |
| thehive.extraConfig | string | `""` | Custom application.conf file for TheHive |
| thehive.extraEnv | list | `[]` | Extra environment variables |
| thehive.indexBackend | object | `{"hostnames":["elasticsearch-master"],"type":"elasticsearch"}` | Index Backend configuration |
| thehive.indexBackend.type | string | `"elasticsearch"` | Elasticsearch is the only supported backend for now |
| thehive.initContainers | object | `{"enabled":true}` | Init containers will execute nslookup to resolve the hostnames of cassandra and elasticsearch |
| thehive.initContainers.enabled | bool | `true` | Enable init containers |
| thehive.livenessProbe | object | `{"enabled":true}` | Liveness probes |
| thehive.maxUnavailable | int | `1` | PodDisruptionBudget configuration |
| thehive.readinessProbe | object | `{"enabled":true}` | Readiness probes |
| thehive.s3 | object | `{"accessKey":"minio","endpoint":"http://thehive-minio:9000","secretKey":"minio123","usePathAccessStyle":true}` | Object Storage configuration |
| thehive.s3.endpoint | string | `"http://thehive-minio:9000"` | S3 Endpoint |
| thehive.secret | string | `"SuperSecretForKubernetes"` | TheHive Secret  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| volumes | list | `[]` | Additional volumes on the output Deployment definition. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
