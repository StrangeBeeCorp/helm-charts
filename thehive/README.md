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
| cassandra.clusterName | string | `"TheHive"` |  |
| cassandra.dcName | string | `"DC1-TheHive"` |  |
| cassandra.enabled | bool | `true` |  |
| cassandra.heapNewSize | string | `"1024M"` |  |
| cassandra.maxHeapSize | string | `"1024M"` |  |
| cassandra.persistence.claimName | string | `"cassandra-pvc"` |  |
| cassandra.persistence.enabled | bool | `true` |  |
| cassandra.persistence.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/hostname"` |  |
| cassandra.persistence.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| cassandra.persistence.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"thehive-control-plane"` |  |
| cassandra.persistence.reclaimPolicy | string | `"Retain"` |  |
| cassandra.persistence.size | string | `"2Gi"` |  |
| cassandra.persistence.storageClass | string | `"standard"` |  |
| cassandra.persistence.volumeMode | string | `"Filesystem"` |  |
| cassandra.persistence.volumeName | string | `"cassandra-pv"` |  |
| cassandra.persistence.volumeType.local.path | string | `"/data/cassandra"` |  |
| cassandra.rackName | string | `"Rack1-TheHive"` |  |
| cassandra.resources.limits.cpu | string | `"1000m"` |  |
| cassandra.resources.limits.memory | string | `"1600Mi"` |  |
| cassandra.resources.requests.cpu | string | `"500m"` |  |
| cassandra.resources.requests.memory | string | `"1600Mi"` |  |
| cassandra.version | string | `"4.1"` |  |
| elasticsearch.antiAffinity | string | `"soft"` |  |
| elasticsearch.createCert | bool | `false` |  |
| elasticsearch.enabled | bool | `true` |  |
| elasticsearch.esConfig."elasticsearch.yml" | string | `"xpack.security.enabled: false\nxpack.security.transport.ssl.enabled: false\nxpack.security.http.ssl.enabled: false\n"` |  |
| elasticsearch.esJavaOpts | string | `"-Xmx128m -Xms128m"` |  |
| elasticsearch.minimumMasterNodes | int | `1` |  |
| elasticsearch.replicas | int | `2` |  |
| elasticsearch.resources.limits.cpu | string | `"1000m"` |  |
| elasticsearch.resources.limits.memory | string | `"512M"` |  |
| elasticsearch.resources.requests.cpu | string | `"100m"` |  |
| elasticsearch.resources.requests.memory | string | `"512M"` |  |
| elasticsearch.secret.enabled | bool | `false` |  |
| elasticsearch.volumeClaimTemplate.accessModes[0] | string | `"ReadWriteOnce"` |  |
| elasticsearch.volumeClaimTemplate.resources.requests.storage | string | `"500M"` |  |
| elasticsearch.volumeClaimTemplate.storageClassName | string | `"standard"` |  |
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
| minio.auth.rootPassword | string | `"minio123"` |  |
| minio.auth.rootUser | string | `"minio"` |  |
| minio.enabled | bool | `true` |  |
| minio.endpoint | string | `"http://thehive-minio:9000"` |  |
| minio.image.repository | string | `"minio/minio"` |  |
| minio.image.tag | string | `"RELEASE.2024-01-18T22-51-28Z"` |  |
| minio.nodeSelector | object | `{}` |  |
| minio.storage.volumeClaimValue | string | `"2Gi"` |  |
| minio.tolerations | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.podReader.attach | bool | `true` |  |
| serviceAccount.podReader.serviceAccountName | string | `""` |  |
| thehive.additionnalConfig.configMapRef | string | `""` |  |
| thehive.clusterMinNodesCount | int | `0` |  |
| thehive.cortex.enabled | bool | `false` |  |
| thehive.cortex.hostnames[0] | string | `"thehive-cortex"` |  |
| thehive.cortex.keys | string | `""` |  |
| thehive.cql.hostnames[0] | string | `"thehive-cassandra"` |  |
| thehive.cql.wait | bool | `true` |  |
| thehive.extraCommand | list | `[]` |  |
| thehive.extraConfig | string | `""` |  |
| thehive.indexBackend.hostnames[0] | string | `"elasticsearch-master"` |  |
| thehive.indexBackend.type | string | `"elasticsearch"` |  |
| thehive.initContainers.enabled | bool | `true` |  |
| thehive.livenessProbe.enabled | bool | `true` |  |
| thehive.maxUnavailable | int | `1` |  |
| thehive.readinessProbe.enabled | bool | `true` |  |
| thehive.s3.accessKey | string | `"minio"` |  |
| thehive.s3.endpoint | string | `"http://thehive-minio:9000"` |  |
| thehive.s3.secretKey | string | `"minio123"` |  |
| thehive.s3.usePathAccessStyle | bool | `true` |  |
| thehive.secret | string | `"SuperSecretForKubernetes"` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
