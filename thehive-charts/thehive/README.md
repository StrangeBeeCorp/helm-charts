# thehive

The official Helm Chart of TheHive for Kubernetes

![Version: 0.4.7](https://img.shields.io/badge/Version-0.4.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.5.11-1](https://img.shields.io/badge/AppVersion-5.5.11--1-informational?style=flat-square)

## Description

The official Helm Chart of TheHive for Kubernetes

Please refer to [StrangeBee's official documentation page](https://docs.strangebee.com/thehive/installation/kubernetes/) for installation instructions and configuration.

**Homepage:** <https://strangebee.com/thehive/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| StrangeBee |  | <https://strangebee.com/> |

## Source Code

* <https://github.com/StrangeBeeCorp/helm-charts/tree/main/thehive-charts/thehive>

## Requirements

Kubernetes: `>= 1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.min.io | minio | 5.4.0 |
| oci://registry-1.docker.io/bitnamicharts | cassandra | 12.3.9 |
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 22.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cassandra.cluster.datacenter | string | `"DC1-TheHive"` |  |
| cassandra.cluster.name | string | `"TheHive"` |  |
| cassandra.cluster.rack | string | `"Rack1-TheHive"` |  |
| cassandra.dbUser.existingSecret | string | `""` |  |
| cassandra.dbUser.forcePassword | bool | `false` |  |
| cassandra.dbUser.password | string | `"ChangeThisPasswordForCassandra"` |  |
| cassandra.dbUser.user | string | `"cassandra"` |  |
| cassandra.enabled | bool | `true` |  |
| cassandra.extraEnvVars[0].name | string | `"CASSANDRA_AUTHENTICATOR"` |  |
| cassandra.extraEnvVars[0].value | string | `"PasswordAuthenticator"` |  |
| cassandra.extraEnvVars[1].name | string | `"CASSANDRA_AUTHORIZER"` |  |
| cassandra.extraEnvVars[1].value | string | `"CassandraAuthorizer"` |  |
| cassandra.global.security.allowInsecureImages | bool | `true` |  |
| cassandra.image.registry | string | `"docker.io"` |  |
| cassandra.image.repository | string | `"bitnamilegacy/cassandra"` |  |
| cassandra.image.tag | string | `"4.1.7-debian-12-r3"` |  |
| cassandra.jvm.extraOpts | string | `"-Xms2g -Xmx2g -Xmn200m"` |  |
| cassandra.jvm.maxHeapSize | string | `"2g"` |  |
| cassandra.jvm.newHeapSize | string | `"200m"` |  |
| cassandra.networkPolicy.enabled | bool | `false` |  |
| cassandra.pdb.create | bool | `true` |  |
| cassandra.pdb.maxUnavailable | string | `"1"` |  |
| cassandra.persistence.enabled | bool | `true` |  |
| cassandra.persistence.size | string | `"10Gi"` |  |
| cassandra.persistence.storageClass | string | `""` |  |
| cassandra.replicaCount | int | `1` |  |
| cassandra.resources.limits.cpu | string | `"2000m"` |  |
| cassandra.resources.limits.ephemeral-storage | string | `"4Gi"` |  |
| cassandra.resources.limits.memory | string | `"3584Mi"` |  |
| cassandra.resources.requests.cpu | string | `"1000m"` |  |
| cassandra.resources.requests.ephemeral-storage | string | `"4Gi"` |  |
| cassandra.resources.requests.memory | string | `"2048Mi"` |  |
| dynamicSeedDiscovery.image.registry | string | `"docker.io"` |  |
| dynamicSeedDiscovery.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| dynamicSeedDiscovery.image.tag | string | `"12-debian-12-r48"` |  |
| elasticsearch.coordinating.replicaCount | int | `0` |  |
| elasticsearch.data.replicaCount | int | `0` |  |
| elasticsearch.enabled | bool | `true` |  |
| elasticsearch.global.security.allowInsecureImages | bool | `true` |  |
| elasticsearch.image.registry | string | `"docker.io"` |  |
| elasticsearch.image.repository | string | `"bitnamilegacy/elasticsearch"` |  |
| elasticsearch.image.tag | string | `"8.18.0-debian-12-r2"` |  |
| elasticsearch.ingest.replicaCount | int | `0` |  |
| elasticsearch.master.extraEnvVars[0].name | string | `"JVM_OPTS"` |  |
| elasticsearch.master.extraEnvVars[0].value | string | `"-Xms2g -Xmx2g -Xmn200m"` |  |
| elasticsearch.master.heapSize | string | `"2g"` |  |
| elasticsearch.master.masterOnly | bool | `false` |  |
| elasticsearch.master.networkPolicy.enabled | bool | `false` |  |
| elasticsearch.master.pdb.create | bool | `true` |  |
| elasticsearch.master.pdb.maxUnavailable | string | `"1"` |  |
| elasticsearch.master.persistence.enabled | bool | `true` |  |
| elasticsearch.master.persistence.size | string | `"10Gi"` |  |
| elasticsearch.master.persistence.storageClass | string | `""` |  |
| elasticsearch.master.replicaCount | int | `1` |  |
| elasticsearch.master.resources.limits.cpu | string | `"2000m"` |  |
| elasticsearch.master.resources.limits.ephemeral-storage | string | `"4Gi"` |  |
| elasticsearch.master.resources.limits.memory | string | `"3584Mi"` |  |
| elasticsearch.master.resources.requests.cpu | string | `"1000m"` |  |
| elasticsearch.master.resources.requests.ephemeral-storage | string | `"4Gi"` |  |
| elasticsearch.master.resources.requests.memory | string | `"2048Mi"` |  |
| elasticsearch.metrics.image.registry | string | `"docker.io"` |  |
| elasticsearch.metrics.image.repository | string | `"bitnamilegacy/elasticsearch-exporter"` |  |
| elasticsearch.metrics.image.tag | string | `"1.9.0-debian-12-r14"` |  |
| elasticsearch.security.elasticPassword | string | `""` |  |
| elasticsearch.security.enabled | bool | `false` |  |
| elasticsearch.security.existingSecret | string | `""` |  |
| elasticsearch.security.tls | object | `{}` |  |
| elasticsearch.sysctlImage.registry | string | `"docker.io"` |  |
| elasticsearch.sysctlImage.repository | string | `"bitnamilegacy/os-shell"` |  |
| elasticsearch.sysctlImage.tag | string | `"12-debian-12-r49"` |  |
| elasticsearch.volumePermissions.image.registry | string | `"docker.io"` |  |
| elasticsearch.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| elasticsearch.volumePermissions.image.tag | string | `"12-debian-12-r49"` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| metrics.image.registry | string | `"docker.io"` |  |
| metrics.image.repository | string | `"bitnamilegacy/cassandra-exporter"` |  |
| metrics.image.tag | string | `"2.3.8-debian-12-r49"` |  |
| minio.buckets[0].name | string | `"thehive"` |  |
| minio.buckets[0].objectlocking | bool | `false` |  |
| minio.buckets[0].policy | string | `"none"` |  |
| minio.buckets[0].purge | bool | `false` |  |
| minio.buckets[0].versioning | bool | `false` |  |
| minio.drivesPerNode | int | `1` |  |
| minio.enabled | bool | `true` |  |
| minio.existingSecret | string | `""` |  |
| minio.image.repository | string | `"quay.io/minio/minio"` |  |
| minio.image.tag | string | `"RELEASE.2025-07-23T15-54-02Z"` |  |
| minio.mcImage.repository | string | `"quay.io/minio/mc"` |  |
| minio.mcImage.tag | string | `"RELEASE.2025-07-21T05-28-08Z"` |  |
| minio.mode | string | `"standalone"` |  |
| minio.persistence.enabled | bool | `true` |  |
| minio.persistence.size | string | `"10Gi"` |  |
| minio.persistence.storageClass | string | `""` |  |
| minio.podDisruptionBudget.enabled | bool | `true` |  |
| minio.podDisruptionBudget.maxUnavailable | int | `1` |  |
| minio.pools | int | `1` |  |
| minio.replicas | int | `1` |  |
| minio.resources.limits.cpu | string | `"1000m"` |  |
| minio.resources.limits.ephemeral-storage | string | `"4Gi"` |  |
| minio.resources.limits.memory | string | `"2Gi"` |  |
| minio.resources.requests.cpu | string | `"500m"` |  |
| minio.resources.requests.ephemeral-storage | string | `"4Gi"` |  |
| minio.resources.requests.memory | string | `"2Gi"` |  |
| minio.rootPassword | string | `"ChangeThisPasswordForMinIO"` |  |
| minio.rootUser | string | `"minio"` |  |
| nameOverride | string | `""` |  |
| thehive.affinity | object | `{}` |  |
| thehive.annotations | object | `{}` |  |
| thehive.autoscaling.enabled | bool | `false` |  |
| thehive.autoscaling.maxReplicas | int | `4` |  |
| thehive.autoscaling.minReplicas | int | `2` |  |
| thehive.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| thehive.clusterMinNodesCount | int | `1` |  |
| thehive.configFile | string | `""` |  |
| thehive.cortex.api_keys | list | `[]` |  |
| thehive.cortex.enabled | bool | `false` |  |
| thehive.cortex.hostnames | list | `[]` |  |
| thehive.cortex.k8sSecretKey | string | `"api-keys"` |  |
| thehive.cortex.k8sSecretName | string | `""` |  |
| thehive.cortex.port | int | `9001` |  |
| thehive.cortex.protocol | string | `"http"` |  |
| thehive.database.hostnames | list | `[]` |  |
| thehive.database.k8sSecretKey | string | `"cassandra-password"` |  |
| thehive.database.k8sSecretName | string | `""` |  |
| thehive.database.password | string | `"ChangeThisPasswordForCassandra"` |  |
| thehive.database.username | string | `"cassandra"` |  |
| thehive.database.wait | bool | `false` |  |
| thehive.extraCommand | list | `[]` |  |
| thehive.extraEnv | list | `[]` |  |
| thehive.httpSecret | string | `"ChangeThisSecretWithOneContainingAtLeast32Chars"` |  |
| thehive.image.pullPolicy | string | `"IfNotPresent"` |  |
| thehive.image.registry | string | `"docker.io"` |  |
| thehive.image.repository | string | `"strangebee/thehive"` |  |
| thehive.image.tag | string | `""` |  |
| thehive.index.hostnames | list | `[]` |  |
| thehive.index.k8sSecretKey | string | `"elasticsearch-password"` |  |
| thehive.index.k8sSecretName | string | `""` |  |
| thehive.index.password | string | `""` |  |
| thehive.index.username | string | `"elastic"` |  |
| thehive.ingress.annotations | object | `{}` |  |
| thehive.ingress.className | string | `""` |  |
| thehive.ingress.enabled | bool | `false` |  |
| thehive.ingress.hosts[0].host | string | `"thehive.example"` |  |
| thehive.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| thehive.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| thehive.ingress.tls | list | `[]` |  |
| thehive.initContainers.checkCassandra.enabled | bool | `true` |  |
| thehive.initContainers.checkElasticsearch.enabled | bool | `true` |  |
| thehive.initContainers.checkElasticsearch.useHttps | bool | `false` |  |
| thehive.initContainers.image.pullPolicy | string | `"IfNotPresent"` |  |
| thehive.initContainers.image.registry | string | `"docker.io"` |  |
| thehive.initContainers.image.repository | string | `"curlimages/curl"` |  |
| thehive.initContainers.image.tag | string | `"8.17.0"` |  |
| thehive.jvmOpts | string | `"-Xms2g -Xmx2g -Xmn300m"` |  |
| thehive.k8sSecretKey | string | `"http-secret"` |  |
| thehive.k8sSecretName | string | `""` |  |
| thehive.labels | object | `{}` |  |
| thehive.livenessProbe.enabled | bool | `true` |  |
| thehive.livenessProbe.failureThreshold | int | `3` |  |
| thehive.livenessProbe.initialDelaySeconds | int | `0` |  |
| thehive.livenessProbe.periodSeconds | int | `10` |  |
| thehive.livenessProbe.timeoutSeconds | int | `1` |  |
| thehive.logbackXml | string | `""` |  |
| thehive.maxUnavailable | int | `1` |  |
| thehive.monitoring.enabled | bool | `true` |  |
| thehive.monitoring.port | int | `9095` |  |
| thehive.nodeSelector | object | `{}` |  |
| thehive.podAnnotations | object | `{}` |  |
| thehive.podLabels | object | `{}` |  |
| thehive.podSecurityContext | object | `{}` |  |
| thehive.readinessProbe.enabled | bool | `true` |  |
| thehive.readinessProbe.failureThreshold | int | `3` |  |
| thehive.readinessProbe.initialDelaySeconds | int | `0` |  |
| thehive.readinessProbe.periodSeconds | int | `10` |  |
| thehive.readinessProbe.successThreshold | int | `1` |  |
| thehive.readinessProbe.timeoutSeconds | int | `1` |  |
| thehive.replicas | int | `1` |  |
| thehive.resources.limits.cpu | string | `"3000m"` |  |
| thehive.resources.limits.ephemeral-storage | string | `"4Gi"` |  |
| thehive.resources.limits.memory | string | `"3584Mi"` |  |
| thehive.resources.requests.cpu | string | `"1000m"` |  |
| thehive.resources.requests.ephemeral-storage | string | `"4Gi"` |  |
| thehive.resources.requests.memory | string | `"2048Mi"` |  |
| thehive.securityContext | object | `{}` |  |
| thehive.service.port | int | `9000` |  |
| thehive.service.type | string | `"ClusterIP"` |  |
| thehive.serviceAccount.annotations | object | `{}` |  |
| thehive.serviceAccount.automountServiceAccountToken | bool | `true` |  |
| thehive.serviceAccount.create | bool | `true` |  |
| thehive.serviceAccount.name | string | `""` |  |
| thehive.startupProbe.enabled | bool | `true` |  |
| thehive.startupProbe.failureThreshold | int | `36` |  |
| thehive.startupProbe.initialDelaySeconds | int | `0` |  |
| thehive.startupProbe.periodSeconds | int | `5` |  |
| thehive.startupProbe.timeoutSeconds | int | `1` |  |
| thehive.storage.accessKey | string | `"minio"` |  |
| thehive.storage.bucket | string | `"thehive"` |  |
| thehive.storage.endpoint | string | `""` |  |
| thehive.storage.k8sSecretKey | string | `"rootPassword"` |  |
| thehive.storage.k8sSecretName | string | `""` |  |
| thehive.storage.region | string | `"us-east-1"` |  |
| thehive.storage.secretKey | string | `"ChangeThisPasswordForMinIO"` |  |
| thehive.storage.usePathAccessStyle | bool | `true` |  |
| thehive.strategy.rollingUpdate.maxSurge | int | `1` |  |
| thehive.strategy.rollingUpdate.maxUnavailable | int | `1` |  |
| thehive.strategy.type | string | `"RollingUpdate"` |  |
| thehive.tolerations | list | `[]` |  |
| thehive.volumeMounts | list | `[]` |  |
| thehive.volumes | list | `[]` |  |
| volumePermissions.image.registry | string | `"docker.io"` |  |
| volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| volumePermissions.image.tag | string | `"12-debian-12-r48"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)