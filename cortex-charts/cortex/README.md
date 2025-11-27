# cortex

Cortex official Helm Chart

[![Version: 0.3.3](https://img.shields.io/badge/Version-0.3.3-informational?style=flat-square) ](https://github.com/StrangeBeeCorp/helm-charts/releases) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  [![AppVersion: 3.2.1-1](https://img.shields.io/badge/AppVersion-3.2.1--1-informational?style=flat-square) ](https://docs.strangebee.com/thehive/release-notes/release-notes-5.5/)

## Description

Cortex official Helm Chart

Please refer to [StrangeBee's official documentation page](https://docs.strangebee.com/cortex/installation-and-configuration/deploy-cortex-on-kubernetes/) for installation instructions and configuration.

**Homepage:** <https://strangebee.com/cortex/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| StrangeBee |  | <https://strangebee.com/> |

## Source Code

* <https://github.com/StrangeBeeCorp/helm-charts/tree/main/cortex-charts/cortex>

## Requirements

Kubernetes: `>= 1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 22.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cortex.affinity | object | `{}` | Affinity rules for pod assignment |
| cortex.annotations | object | `{}` | Additional annotations to attach to Cortex resources |
| cortex.configFile | string | `"# Cortex configuration file\n# See https://docs.strangebee.com/cortex/installation-and-configuration/#configuration-guides\nanalyzer {\n  urls: [\n    \"https://catalogs.download.strangebee.com/latest/json/analyzers.json\",\n  ]\n\n  # Customize analyzers parallelism here\n  fork-join-executor {\n    parallelism-min: 8,\n    parallelism-factor: 1.0,\n    parallelism-max: 8,\n  }\n}\n\n  # Customize responders parallelism here\nresponder {\n  urls: [\n    \"https://catalogs.download.strangebee.com/latest/json/responders.json\",\n  ]\n\n  fork-join-executor {\n    parallelism-min: 8,\n    parallelism-factor: 1.0,\n    parallelism-max: 8,\n  }\n}\n\n# ElasticSearch\nsearch {\n  # Set default value for the password\n  password = \"\"\n  # Override credentials (if these environment variables exist)\n  user = ${?CORTEX_ELASTICSEARCH_USERNAME}\n  password = ${?CORTEX_ELASTICSEARCH_PASSWORD}\n}\n"` | Custom application.conf configuration file content for Cortex |
| cortex.extraCommand | list | `[]` | Extra command-line arguments for Cortex entrypoint |
| cortex.extraEnv | list | `[]` | Extra environment variables for Cortex container |
| cortex.httpSecret | string | `"ChangeThisSecretWithOneContainingAtLeast32Chars"` | HTTP secret for Cortex application (must be at least 32 characters) |
| cortex.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| cortex.image.registry | string | `"docker.io"` | Docker registry for Cortex image |
| cortex.image.repository | string | `"thehiveproject/cortex"` | Cortex image repository |
| cortex.image.tag | string | `""` | Cortex image tag (defaults to chart appVersion if not set) |
| cortex.index.hostnames | list | `[]` | List of ElasticSearch hostnames (auto-configured if ElasticSearch subchart is enabled and this is empty) |
| cortex.index.k8sSecretKey | string | `"elasticsearch-password"` | Key in the secret containing ElasticSearch password |
| cortex.index.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing ElasticSearch password |
| cortex.index.password | string | `""` | ElasticSearch password for index connection (should match ElasticSearch subchart credentials if enabled) |
| cortex.index.username | string | `"elastic"` | ElasticSearch username for index connection |
| cortex.ingress.annotations | object | `{}` | Ingress annotations |
| cortex.ingress.className | string | `""` | Ingress class name |
| cortex.ingress.enabled | bool | `false` | Enable ingress resource creation |
| cortex.ingress.hosts | list | `[{"host":"cortex.example","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts configuration |
| cortex.ingress.tls | list | `[]` | Ingress TLS configuration |
| cortex.initContainers.checkElasticsearch.enabled | bool | `true` | Enable init container to wait for ElasticSearch readiness |
| cortex.initContainers.checkElasticsearch.useHttps | bool | `false` | Use HTTPS for ElasticSearch readiness check |
| cortex.initContainers.image.pullPolicy | string | `"IfNotPresent"` | Init container image pull policy |
| cortex.initContainers.image.registry | string | `"docker.io"` | Docker registry for init container image |
| cortex.initContainers.image.repository | string | `"curlimages/curl"` | Init container image repository |
| cortex.initContainers.image.tag | string | `"8.17.0"` | Init container image tag |
| cortex.jobDirectory | string | `"/tmp/cortex-jobs"` | Directory in Cortex container used to communicate with running jobs (write inputs and read outputs) |
| cortex.jvmOpts | string | `"-Xms2g -Xmx2g -Xmn300m"` | JVM options for Cortex application |
| cortex.k8sSecretKey | string | `"http-secret"` | Key in the secret containing Cortex HTTP secret |
| cortex.k8sSecretName | string | `""` | Name of existing Kubernetes secret containing Cortex HTTP secret |
| cortex.labels | object | `{}` | Additional labels to attach to Cortex resources |
| cortex.livenessProbe.enabled | bool | `true` | Enable liveness probe |
| cortex.livenessProbe.failureThreshold | int | `3` | Number of failures before restarting container |
| cortex.livenessProbe.initialDelaySeconds | int | `0` | Initial delay before liveness probe begins |
| cortex.livenessProbe.periodSeconds | int | `10` | Frequency of liveness probe checks |
| cortex.livenessProbe.timeoutSeconds | int | `1` | Timeout for each liveness probe attempt |
| cortex.logbackXml | string | `""` | Custom logback.xml logging configuration file content for Cortex |
| cortex.nodeSelector | object | `{}` | Node selector for pod assignment |
| cortex.persistentVolumeClaim.create | bool | `true` | Create a PVC or use an existing one (ReadWriteMany accessMode is MANDATORY for Cortex to share data with job pods) |
| cortex.persistentVolumeClaim.name | string | `""` | Name of the PVC to create/use (auto-generated if empty and create is true) |
| cortex.persistentVolumeClaim.size | string | `"10Gi"` | Size of the persistent volume |
| cortex.persistentVolumeClaim.storageClass | string | `""` | Storage class for persistent volume (use "-" to disable dynamic provisioning, "" for default provisioner) |
| cortex.podAnnotations | object | `{}` | Additional annotations to attach to Cortex pods |
| cortex.podLabels | object | `{}` | Additional labels to attach to Cortex pods |
| cortex.podSecurityContext | object | `{}` | Pod-wide security context |
| cortex.readinessProbe.enabled | bool | `true` | Enable readiness probe |
| cortex.readinessProbe.failureThreshold | int | `3` | Number of failures before marking pod as not ready |
| cortex.readinessProbe.initialDelaySeconds | int | `0` | Initial delay before readiness probe begins |
| cortex.readinessProbe.periodSeconds | int | `10` | Frequency of readiness probe checks |
| cortex.readinessProbe.successThreshold | int | `1` | Number of successes before marking pod as ready |
| cortex.readinessProbe.timeoutSeconds | int | `1` | Timeout for each readiness probe attempt |
| cortex.replicas | int | `1` | Number of Cortex replicas |
| cortex.resources | object | `{"limits":{"cpu":"3000m","ephemeral-storage":"4Gi","memory":"3584Mi"},"requests":{"cpu":"1000m","ephemeral-storage":"4Gi","memory":"2048Mi"}}` | Resource requests and limits for Cortex pods |
| cortex.securityContext | object | `{}` | Container-level security context |
| cortex.service.port | int | `9001` | Cortex application port |
| cortex.service.type | string | `"ClusterIP"` | Kubernetes service type |
| cortex.serviceAccount.annotations | object | `{}` | Annotations for the service account |
| cortex.serviceAccount.automountServiceAccountToken | bool | `true` | Automatically mount Kubernetes API credentials |
| cortex.serviceAccount.create | bool | `true` | Create a service account for Cortex |
| cortex.serviceAccount.name | string | `""` | Name of the service account (generated if empty) |
| cortex.startupProbe.enabled | bool | `true` | Enable startup probe (set failureThreshold high to prevent CrashLoops during schema migrations) |
| cortex.startupProbe.failureThreshold | int | `36` | Number of failures before marking pod as failed |
| cortex.startupProbe.initialDelaySeconds | int | `0` | Initial delay before startup probe begins |
| cortex.startupProbe.periodSeconds | int | `5` | Frequency of startup probe checks |
| cortex.startupProbe.timeoutSeconds | int | `1` | Timeout for each startup probe attempt |
| cortex.strategy.rollingUpdate.maxSurge | int | `1` | Maximum number of pods that can be created over the desired number of pods |
| cortex.strategy.rollingUpdate.maxUnavailable | int | `0` | Maximum number of pods that can be unavailable during the update |
| cortex.strategy.type | string | `"RollingUpdate"` | Deployment strategy type |
| cortex.tolerations | list | `[]` | Tolerations for pod assignment |
| cortex.volumeMounts | list | `[]` | Additional volume mounts for Cortex container |
| cortex.volumes | list | `[]` | Additional volumes for Cortex deployment |
| elasticsearch.coordinating.replicaCount | int | `0` | Number of coordinating-dedicated node replicas (disabled by default) |
| elasticsearch.data.replicaCount | int | `0` | Number of data-dedicated node replicas (disabled by default) |
| elasticsearch.enabled | bool | `true` | Enable ElasticSearch dependency subchart deployment |
| elasticsearch.global.security.allowInsecureImages | bool | `true` | Allow insecure images to use bitnamilegacy repository |
| elasticsearch.image.registry | string | `"docker.io"` | ElasticSearch image registry (Cortex only supports ElasticSearch v7) |
| elasticsearch.image.repository | string | `"bitnamilegacy/elasticsearch"` | ElasticSearch image repository |
| elasticsearch.image.tag | string | `"7.17.26-debian-12-r0"` | ElasticSearch image tag |
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
| elasticsearch.metrics.image.tag | string | `"1.9.0-debian-12-r14"` | ElasticSearch metrics exporter image tag |
| elasticsearch.security.elasticPassword | string | `""` | ElasticSearch elastic user password |
| elasticsearch.security.enabled | bool | `false` | Enable security features (requires TLS configuration) |
| elasticsearch.security.existingSecret | string | `""` | Name of existing secret with ElasticSearch password (expects .data.elasticsearch-password key) |
| elasticsearch.security.tls | object | `{}` | TLS configuration for ElasticSearch |
| elasticsearch.sysctlImage.registry | string | `"docker.io"` | Sysctl init container image registry |
| elasticsearch.sysctlImage.repository | string | `"bitnamilegacy/os-shell"` | Sysctl init container image repository |
| elasticsearch.sysctlImage.tag | string | `"12-debian-12-r49"` | Sysctl init container image tag |
| elasticsearch.volumePermissions.image.registry | string | `"docker.io"` | Volume permissions init container image registry |
| elasticsearch.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` | Volume permissions init container image repository |
| elasticsearch.volumePermissions.image.tag | string | `"12-debian-12-r49"` | Volume permissions init container image tag |
| fullnameOverride | string | `""` | Override the full name of the chart |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| nameOverride | string | `""` | Override the name of the chart |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)