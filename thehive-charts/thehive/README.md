# thehive

The official Helm Chart of TheHive for Kubernetes

[![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ](https://github.com/StrangeBeeCorp/helm-charts/releases) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  [![AppVersion: 5.5.13-1](https://img.shields.io/badge/AppVersion-5.5.13--1-informational?style=flat-square) ](https://docs.strangebee.com/thehive/release-notes/release-notes-5.5/)

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
| oci://registry-1.docker.io/bitnamicharts | cassandra | 12.3.11 |
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 22.1.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cassandra.cluster.datacenter | string | `"DC1-TheHive"` | Cassandra datacenter name |
| cassandra.cluster.name | string | `"TheHive"` | Cassandra cluster name |
| cassandra.cluster.rack | string | `"Rack1-TheHive"` | Cassandra rack name |
| cassandra.dbUser.existingSecret | string | `""` | Name of existing secret with Cassandra password (expects .data.cassandra-password key) |
| cassandra.dbUser.forcePassword | bool | `false` | Force password update on deployment |
| cassandra.dbUser.password | string | `"ChangeThisPasswordForCassandra"` | Cassandra database password |
| cassandra.dbUser.user | string | `"cassandra"` | Cassandra database username |
| cassandra.enabled | bool | `true` | Enable Cassandra dependency subchart deployment |
| cassandra.extraEnvVars | list | `[{"name":"CASSANDRA_AUTHENTICATOR","value":"PasswordAuthenticator"},{"name":"CASSANDRA_AUTHORIZER","value":"CassandraAuthorizer"}]` | Extra environment variables for Cassandra |
| cassandra.extraEnvVars[0] | object | `{"name":"CASSANDRA_AUTHENTICATOR","value":"PasswordAuthenticator"}` | Cassandra authenticator (use AllowAllAuthenticator for passwordless) |
| cassandra.extraEnvVars[1] | object | `{"name":"CASSANDRA_AUTHORIZER","value":"CassandraAuthorizer"}` | Cassandra authorizer (use AllowAllAuthorizer for passwordless) |
| cassandra.global.security.allowInsecureImages | bool | `true` | Allow the use of insecure images from bitnamilegacy repository |
| cassandra.image.registry | string | `"docker.io"` | Cassandra image registry |
| cassandra.image.repository | string | `"bitnamilegacy/cassandra"` | Cassandra image repository |
| cassandra.image.tag | string | `"4.1.7-debian-12-r3"` | Cassandra image tag |
| cassandra.jvm.extraOpts | string | `"-Xms2g -Xmx2g -Xmn200m"` | Additional JVM options for Cassandra |
| cassandra.jvm.maxHeapSize | string | `"2g"` | Maximum heap size for Cassandra JVM |
| cassandra.jvm.newHeapSize | string | `"200m"` | New generation heap size for Cassandra JVM |
| cassandra.networkPolicy.enabled | bool | `false` | Enable network policy for Cassandra |
| cassandra.pdb.create | bool | `true` | Create PodDisruptionBudget for Cassandra |
| cassandra.pdb.maxUnavailable | string | `"1"` | Maximum unavailable Cassandra pods |
| cassandra.persistence.enabled | bool | `true` | Enable persistent volume for Cassandra data |
| cassandra.persistence.size | string | `"10Gi"` | Size of Cassandra persistent volume |
| cassandra.persistence.storageClass | string | `""` | Storage class for Cassandra persistent volume |
| cassandra.replicaCount | int | `1` | Number of Cassandra replicas |
| cassandra.resources | object | `{"limits":{"cpu":"2000m","ephemeral-storage":"4Gi","memory":"3584Mi"},"requests":{"cpu":"1000m","ephemeral-storage":"4Gi","memory":"2048Mi"}}` | Resource requests and limits for Cassandra pods |
| dynamicSeedDiscovery.image.registry | string | `"docker.io"` | Dynamic seed discovery image registry |
| dynamicSeedDiscovery.image.repository | string | `"bitnamilegacy/os-shell"` | Dynamic seed discovery image repository |
| dynamicSeedDiscovery.image.tag | string | `"12-debian-12-r51"` | Dynamic seed discovery image tag |
| elasticsearch.coordinating.replicaCount | int | `0` | Number of coordinating-dedicated node replicas (disabled by default) |
| elasticsearch.data.replicaCount | int | `0` | Number of data-dedicated node replicas (disabled by default) |
| elasticsearch.enabled | bool | `true` | Enable ElasticSearch dependency subchart deployment |
| elasticsearch.global.security.allowInsecureImages | bool | `true` | Allow the use of insecure images from bitnamilegacy repository |
| elasticsearch.image.registry | string | `"docker.io"` | ElasticSearch image registry |
| elasticsearch.image.repository | string | `"bitnamilegacy/elasticsearch"` | ElasticSearch image repository |
| elasticsearch.image.tag | string | `"9.1.2-debian-12-r0"` | ElasticSearch image tag |
| elasticsearch.ingest.replicaCount | int | `0` | Number of ingest-dedicated node replicas (disabled by default) |
| elasticsearch.master.extraEnvVars | list | `[{"name":"JVM_OPTS","value":"-Xms2g -Xmx2g -Xmn200m"}]` | Extra environment variables for ElasticSearch master nodes |
| elasticsearch.master.heapSize | string | `"2g"` | Heap size for ElasticSearch master nodes |
| elasticsearch.master.masterOnly | bool | `false` | Deploy master-only nodes or multipurpose nodes (master, data, coordinating, ingest) |
| elasticsearch.master.networkPolicy.enabled | bool | `false` | Enable network policy for ElasticSearch master nodes |
| elasticsearch.master.pdb.create | bool | `true` | Create PodDisruptionBudget for ElasticSearch master nodes |
| elasticsearch.master.pdb.maxUnavailable | string | `"1"` | Maximum unavailable master nodes |
| elasticsearch.master.persistence.enabled | bool | `true` | Enable persistent volume for ElasticSearch master nodes |
| elasticsearch.master.persistence.size | string | `"10Gi"` | Size of ElasticSearch master node persistent volume |
| elasticsearch.master.persistence.storageClass | string | `""` | Storage class for ElasticSearch master node persistent volume |
| elasticsearch.master.replicaCount | int | `1` | Number of master-eligible ElasticSearch replicas |
| elasticsearch.master.resources | object | `{"limits":{"cpu":"2000m","ephemeral-storage":"4Gi","memory":"3584Mi"},"requests":{"cpu":"1000m","ephemeral-storage":"4Gi","memory":"2048Mi"}}` | Resource requests and limits for ElasticSearch master nodes |
| elasticsearch.metrics.image.registry | string | `"docker.io"` | ElasticSearch metrics exporter image registry |
| elasticsearch.metrics.image.repository | string | `"bitnamilegacy/elasticsearch-exporter"` | ElasticSearch metrics exporter image repository |
| elasticsearch.metrics.image.tag | string | `"1.9.0-debian-12-r16"` | ElasticSearch metrics exporter image tag |
| elasticsearch.security.elasticPassword | string | `""` | ElasticSearch elastic user password |
| elasticsearch.security.enabled | bool | `false` | Enable security features (requires TLS configuration) |
| elasticsearch.security.existingSecret | string | `""` | Name of existing secret with ElasticSearch password (expects .data.elasticsearch-password key) |
| elasticsearch.security.tls | object | `{}` | TLS configuration for ElasticSearch |
| elasticsearch.sysctlImage.registry | string | `"docker.io"` | Sysctl init container image registry |
| elasticsearch.sysctlImage.repository | string | `"bitnamilegacy/os-shell"` | Sysctl init container image repository |
| elasticsearch.sysctlImage.tag | string | `"12-debian-12-r51"` | Sysctl init container image tag |
| elasticsearch.volumePermissions.image.registry | string | `"docker.io"` | Volume permissions init container image registry |
| elasticsearch.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` | Volume permissions init container image repository |
| elasticsearch.volumePermissions.image.tag | string | `"12-debian-12-r51"` | Volume permissions init container image tag |
| fullnameOverride | string | `""` | Override the full name of the chart |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| metrics.image.registry | string | `"docker.io"` | Cassandra metrics exporter image registry |
| metrics.image.repository | string | `"bitnamilegacy/cassandra-exporter"` | Cassandra metrics exporter image repository |
| metrics.image.tag | string | `"2.3.8-debian-12-r51"` | Cassandra metrics exporter image tag |
| minio.buckets | list | `[{"name":"thehive","objectlocking":false,"policy":"none","purge":false,"versioning":false}]` | MinIO bucket configuration |
| minio.drivesPerNode | int | `1` | Number of drives per MinIO node |
| minio.enabled | bool | `true` | Enable [MinIO](https://github.com/minio/minio/blob/master/helm/minio/values.yaml) dependency subchart deployment (disable if using external S3-compatible storage or a filesystem shared between pods) |
| minio.existingSecret | string | `""` | Name of existing secret with MinIO credentials (expects .data.rootUser and .data.rootPassword keys) |
| minio.image.repository | string | `"quay.io/minio/minio"` | MinIO image repository |
| minio.image.tag | string | `"RELEASE.2025-09-07T16-13-09Z"` | MinIO image tag |
| minio.mcImage.repository | string | `"quay.io/minio/mc"` | MinIO client (mc) image repository |
| minio.mcImage.tag | string | `"RELEASE.2025-08-13T08-35-41Z"` | MinIO client (mc) image tag |
| minio.mode | string | `"standalone"` | MinIO deployment mode (standalone or distributed) |
| minio.persistence.enabled | bool | `true` | Enable persistent volume for MinIO data |
| minio.persistence.size | string | `"10Gi"` | Size of MinIO persistent volume |
| minio.persistence.storageClass | string | `""` | Storage class for MinIO persistent volume |
| minio.podDisruptionBudget.enabled | bool | `true` | Enable PodDisruptionBudget for MinIO |
| minio.podDisruptionBudget.maxUnavailable | int | `1` | Maximum unavailable MinIO pods |
| minio.pools | int | `1` | Number of expanded MinIO clusters |
| minio.replicas | int | `1` | Number of MinIO pod replicas |
| minio.resources | object | `{"limits":{"cpu":"1000m","ephemeral-storage":"4Gi","memory":"2Gi"},"requests":{"cpu":"500m","ephemeral-storage":"4Gi","memory":"2Gi"}}` | Resource requests and limits for MinIO pods |
| minio.rootPassword | string | `"ChangeThisPasswordForMinIO"` | MinIO root password |
| minio.rootUser | string | `"minio"` | MinIO root username |
| nameOverride | string | `""` | Override the name of the chart |
| thehive.affinity | object | `{}` | Affinity rules for pod assignment |
| thehive.annotations | object | `{}` | Additional annotations to attach to TheHive resources |
| thehive.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| thehive.autoscaling.maxReplicas | int | `4` | Maximum number of replicas for autoscaling |
| thehive.autoscaling.minReplicas | int | `2` | Minimum number of replicas for autoscaling |
| thehive.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for autoscaling |
| thehive.clusterMinNodesCount | int | `1` | Minimum number of TheHive nodes to form a cluster |
| thehive.configFile | string | `""` | Custom application.conf configuration file content for TheHive |
| thehive.cortex.api_keys | list | `[]` | Cortex API keys (each key maps to a hostname in order) |
| thehive.cortex.enabled | bool | `false` | Enable Cortex integration (can also configure Cortex servers from TheHive UI) |
| thehive.cortex.hostnames | list | `[]` | List of Cortex server hostnames |
| thehive.cortex.k8sSecretKey | string | `"api-keys"` | Key in the secret containing Cortex API keys |
| thehive.cortex.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing Cortex API keys (comma-separated format) |
| thehive.cortex.port | int | `9001` | Cortex server port |
| thehive.cortex.protocol | string | `"http"` | Cortex protocol (http or https) |
| thehive.database.hostnames | list | `[]` | List of Cassandra hostnames (auto-configured if Cassandra subchart is enabled and this is empty) |
| thehive.database.k8sSecretKey | string | `"cassandra-password"` | Key in the secret containing Cassandra password |
| thehive.database.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing Cassandra password |
| thehive.database.password | string | `"ChangeThisPasswordForCassandra"` | Cassandra password for database connection (should match Cassandra subchart credentials if enabled) |
| thehive.database.username | string | `"cassandra"` | Cassandra username for database connection |
| thehive.database.wait | bool | `false` | Wait 30 seconds before starting TheHive (can be used to give time for Cassandra to start) |
| thehive.extraCommand | list | `[]` | Extra command-line arguments for TheHive entrypoint |
| thehive.extraEnv | list | `[]` | Extra environment variables for TheHive container |
| thehive.httpSecret | string | `"ChangeThisSecretWithOneContainingAtLeast32Chars"` | HTTP secret for TheHive application (must be at least 32 characters) |
| thehive.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| thehive.image.registry | string | `"docker.io"` | Docker registry for TheHive image |
| thehive.image.repository | string | `"strangebee/thehive"` | TheHive image repository |
| thehive.image.tag | string | `""` | TheHive image tag (defaults to chart appVersion if not set) |
| thehive.index.hostnames | list | `[]` | List of ElasticSearch hostnames (auto-configured if ElasticSearch subchart is enabled and this is empty) |
| thehive.index.k8sSecretKey | string | `"elasticsearch-password"` | Key in the secret containing ElasticSearch password |
| thehive.index.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing ElasticSearch password |
| thehive.index.password | string | `""` | ElasticSearch password for index connection (should match ElasticSearch subchart credentials if enabled) |
| thehive.index.username | string | `"elastic"` | ElasticSearch username for index connection |
| thehive.ingress.annotations | object | `{}` | Ingress annotations |
| thehive.ingress.className | string | `""` | Ingress class name |
| thehive.ingress.enabled | bool | `false` | Enable ingress resource creation |
| thehive.ingress.hosts | list | `[{"host":"thehive.example","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts configuration |
| thehive.ingress.hosts[0] | object | `{"host":"thehive.example","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}` | A DNS name to access TheHive |
| thehive.ingress.tls | list | `[]` | Ingress TLS configuration |
| thehive.initContainers.checkCassandra.enabled | bool | `true` | Add an init container waiting for Cassandra to listen on port 9042 |
| thehive.initContainers.checkElasticsearch.enabled | bool | `true` | Add an init container waiting for ElasticSearch to answer when requested /_cluster/health route on port 9200 |
| thehive.initContainers.checkElasticsearch.useHttps | bool | `false` | Use HTTPS for ElasticSearch availability check |
| thehive.initContainers.image.pullPolicy | string | `"IfNotPresent"` | Init container image pull policy |
| thehive.initContainers.image.registry | string | `"docker.io"` | Docker registry for init container image |
| thehive.initContainers.image.repository | string | `"curlimages/curl"` | Init container image repository |
| thehive.initContainers.image.tag | string | `"8.17.0"` | Init container image tag |
| thehive.jvmOpts | string | `"-Xms2g -Xmx2g -Xmn300m"` | JVM options for TheHive application |
| thehive.k8sSecretKey | string | `"http-secret"` | Key in the secret containing TheHive HTTP secret |
| thehive.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing TheHive HTTP secret |
| thehive.labels | object | `{}` | Additional labels to attach to TheHive resources |
| thehive.livenessProbe.enabled | bool | `true` | Enable liveness probe |
| thehive.livenessProbe.failureThreshold | int | `3` | Number of failures before restarting container |
| thehive.livenessProbe.initialDelaySeconds | int | `0` | Initial delay before liveness probe begins |
| thehive.livenessProbe.periodSeconds | int | `10` | Frequency of liveness probe checks |
| thehive.livenessProbe.timeoutSeconds | int | `1` | Timeout for each liveness probe attempt |
| thehive.logbackXml | string | `""` | Custom logback.xml logging configuration file content for TheHive |
| thehive.maxUnavailable | int | `1` | Maximum number of unavailable pods in PodDisruptionBudget |
| thehive.monitoring.enabled | bool | `true` | Enable monitoring port exposure (edit application.conf to configure Kamon) |
| thehive.monitoring.port | int | `9095` | Monitoring metrics port |
| thehive.nodeSelector | object | `{}` | Node selector for pod assignment |
| thehive.podAnnotations | object | `{}` | Additional annotations to attach to TheHive pods |
| thehive.podLabels | object | `{}` | Additional labels to attach to TheHive pods |
| thehive.podSecurityContext | object | `{}` | Pod-wide security context |
| thehive.readinessProbe.enabled | bool | `true` | Enable readiness probe |
| thehive.readinessProbe.failureThreshold | int | `3` | Number of failures before marking pod as not ready |
| thehive.readinessProbe.initialDelaySeconds | int | `0` | Initial delay before readiness probe begins |
| thehive.readinessProbe.periodSeconds | int | `10` | Frequency of readiness probe checks |
| thehive.readinessProbe.successThreshold | int | `1` | Number of successes before marking pod as ready |
| thehive.readinessProbe.timeoutSeconds | int | `1` | Timeout for each readiness probe attempt |
| thehive.replicas | int | `1` | Number of TheHive replicas (only used when thehive.autoscaling.enabled is false) |
| thehive.resources | object | `{"limits":{"cpu":"3000m","ephemeral-storage":"4Gi","memory":"3584Mi"},"requests":{"cpu":"1000m","ephemeral-storage":"4Gi","memory":"2048Mi"}}` | Resource requests and limits for TheHive pods |
| thehive.securityContext | object | `{}` | Container-level security context |
| thehive.service.port | int | `9000` | TheHive application port |
| thehive.service.type | string | `"ClusterIP"` | Kubernetes service type |
| thehive.serviceAccount.annotations | object | `{}` | Annotations for the service account |
| thehive.serviceAccount.automountServiceAccountToken | bool | `true` | Automatically mount Kubernetes API credentials |
| thehive.serviceAccount.create | bool | `true` | Create a service account for TheHive |
| thehive.serviceAccount.name | string | `""` | Name of the service account (generated if empty) |
| thehive.startupProbe.enabled | bool | `true` | Enable startup probe (set failureThreshold high to prevent CrashLoops during schema migrations) |
| thehive.startupProbe.failureThreshold | int | `36` | Number of failures before marking pod as failed |
| thehive.startupProbe.initialDelaySeconds | int | `0` | Initial delay before startup probe begins |
| thehive.startupProbe.periodSeconds | int | `5` | Frequency of startup probe checks |
| thehive.startupProbe.timeoutSeconds | int | `1` | Timeout for each startup probe attempt |
| thehive.storage.accessKey | string | `"minio"` | Access key for object storage connection (should match MinIO subchart credentials if enabled) |
| thehive.storage.bucket | string | `"thehive"` | Object storage bucket name for TheHive data |
| thehive.storage.endpoint | string | `""` | Object storage endpoint URL (auto-configured if MinIO subchart is enabled and this is empty) |
| thehive.storage.k8sSecretKey | string | `"rootPassword"` | Key in the secret containing object storage secret key |
| thehive.storage.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing object storage secret key |
| thehive.storage.region | string | `"us-east-1"` | Object storage region |
| thehive.storage.secretKey | string | `"ChangeThisPasswordForMinIO"` | Secret key for object storage connection (should match MinIO subchart credentials if enabled) |
| thehive.storage.usePathAccessStyle | bool | `true` | Use path-style access for object storage (required for MinIO) |
| thehive.strategy.rollingUpdate.maxSurge | int | `1` | Maximum number of pods that can be created over the desired number of pods (only for RollingUpdate) |
| thehive.strategy.rollingUpdate.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during the update (only for RollingUpdate) |
| thehive.strategy.type | string | `"RollingUpdate"` | Deployment strategy type. Set to "RollingUpdate" or "Recreate" depending on HA needs and TheHive version upgrade (schema migrations) |
| thehive.tolerations | list | `[]` | Tolerations for pod assignment |
| thehive.volumeMounts | list | `[]` | Additional volume mounts for TheHive container |
| thehive.volumes | list | `[]` | Additional volumes for TheHive deployment |
| volumePermissions.image.registry | string | `"docker.io"` | Volume permissions init container image registry |
| volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` | Volume permissions init container image repository |
| volumePermissions.image.tag | string | `"12-debian-12-r51"` | Volume permissions init container image tag |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
