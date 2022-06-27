# TheHive

## helm charts

The canonical source for Helm charts is the [Helm Hub](https://hub.helm.sh/), an aggregator for distributed chart repos.
For more information about installing and using Helm, see the
[Helm Docs](https://helm.sh/docs/). For a quick introduction to Charts, see the [Chart Guide](https://helm.sh/docs/topics/charts/).

Step by step to install [Quick installation](https://github.com/StrangeBeeCorp/helm-charts/tree/main#install)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

# More About

## [_Cassandra_](https://github.com/StrangeBeeCorp/helm-charts/blob/main/charts/cassandra/README.md) | [_ElasticSearch_](https://github.com/StrangeBeeCorp/helm-charts/blob/main/charts/cassandra/README.md)

<!-- TODO: CHECK BELOW DOCUMENTATION 21~43 -->
## Important Informations
  ### Storage
  Change the value of TheHiveStorageClass.cloud according to the cloud where the cluster is running.
  ```bash
    helm upgrade thehive ./thehive --values ./thehive/values.yaml -n thehive --set TheHiveStorageClass.cloud=google
  ```

  If it is running locally, set this parameter to the value "local".
   
  ```bash
  helm upgrade thehive ./thehive --values ./thehive/values.yaml -n thehive --set TheHiveStorageClass.cloud=local
  ```
  ### ElasticSearch and Canssandra
  If you don't have elasticsearch or cassandra installed it is necessary to pass the hotname in the following variables.
  
  ElasticSeach hostname:
  ```bash
    helm upgrade thehive ./thehive --values ./thehive/values.yaml -n thehive --set .Values.hostnames.elasticSearch.value=HOSTNAME
  ```
  Cassandra hostname:
  ```bash
    helm upgrade thehive ./thehive --values ./thehive/values.yaml -n thehive --set .Values.hostnames.cassandra.value=HOSTNAME
  ```

## Thehive Parameters

| Name                                               | Description                         | Value                                           |
| -------------------------------------------------- | ----------------------------------- | ----------------------------------------------- |
| `theHiveApp.service.type`                          | type of thehive Service             | `LoadBalancer`                                  |
| `theHiveApp.service.port`                          | port of service                     | `9000`                                          |
| `theHiveApp.service.nodePort`                      | node port of thehive service        | `30001`                                         |
| `theHiveApp.Statefulset.replicas`                  | number of thehive replicas          | `1`                                             |
| `theHiveApp.Statefulset.ContainerPort`             | Container port of thehive container | `9000`                                          |
| `theHiveApp.Statefulset.name`                      | name of thehive container           | `http`                                          |
| `theHiveApp.Statefulset.resources.limits.memory`   | memory limit of thehive container   | `2Gi`                                           |
| `theHiveApp.Statefulset.resources.requests.cpu`    | min cpu provisioneted by cluster    | `100m`                                          |
| `theHiveApp.Statefulset.resources.requests.memory` | min memoru provisioneted by clutes  | `100Mi`                                         |
| `theHiveApp.Statefulset.image`                     | thehive's image                     | `strangebee/thehive:latest`                     |
| `theHiveApp.cassandraHostname`                     | elasticSearch hostname              | `cassandra`                                     |
| `theHiveApp.elasticSearchHostname`                 | elasticSearch hostname              | `elasticsearch.elasticsearch.svc.cluster.local` |

## Cortex Parameters

| Name                                                      | Description                        | Value                        |
| --------------------------------------------------------- | ---------------------------------- | ---------------------------- |
| `cortex.service.type`                                     | type of cortex Service             | `LoadBalancer`               |
| `cortex.service.port`                                     | port of service                    | `9543`                       |
| `cortex.service.targetPort`                               | node port of cortex service        | `9001`                       |
| `cortex.Statefulset.replicas`                             | number of cortex replicas          | `1`                          |
| `cortex.Statefulset.terminationGracePeriodSeconds`        | time expected to shutdown pod      | `1800`                       |
| `cortex.Statefulset.contianers.image`                     | cortex's image                     | `strangebee/cortex::3.1.1-1` |
| `cortex.Statefulset.contianers.ports.name`                | name of cortex container           | `http`                       |
| `cortex.Statefulset.contianers.ports.ContainerPort`       | Container port of cortex container | `9001`                       |
| `cortex.Statefulset.contianers.resources.limits.memory`   | memory limit of cortex container   | `1Gi`                        |
| `cortex.Statefulset.contianers.resources.limits.cpu`      | cpu limit of cortex container      | `500m`                       |
| `cortex.Statefulset.contianers.resources.requests.cpu`    | min cpu provisioneted by cluster   | `100m`                       |
| `cortex.Statefulset.contianers.resources.requests.memory` | min memoru provisioneted by clutes | `512Mi`                      |

## Minio Parameters

| Name                                                      | Description                        | Value                 |
| --------------------------------------------------------- | ---------------------------------- | --------------------- |
| `minio.service.type`                                      | type of minio Service              | `LoadBalancer`        |
| `minio.service.apiName`                                   | minio's service name               | `api`                 |
| `minio.service.apiPort`                                   | minio's port                       | `9017`                |
| `minio.service.apitargetPort`                             | minio's targetPort                 | `9000`                |
| `minio.service.consoleName`                               | minio's service name               | `console`             |
| `minio.service.consolePort`                               | minio's port                       | `9018`                |
| `minio.service.consoletargetPort`                         | minio's targetPort                 | `9001`                |
| `minio.service.consoleNodePort`                           | minio's nodePort                   | `30018`               |
| `minio.Statefulset.replicas`                              | number of thehive replicas         | `1`                   |
| `minio.Statefulset.terminationGracePeriodSeconds`         | time expected to shutdown pod      | `1800`                |
| `minio.Statefulset.contianers.image`                      | thehive's image                    | `quay.io/minio/minio` |
| `minio.Statefulset.contianers.ports.apiName`              | name of minio api container        | `api`                 |
| `minio.Statefulset.contianers.ports.apiContainerPort`     | Container port of minio api        | `9000`                |
| `minio.Statefulset.contianers.ports.consoleName`          | name of minio console container    | `console`             |
| `minio.Statefulset.contianers.ports.consoleContainerPort` | Container port of minio console    | `9001`                |
| `minio.Statefulset.contianers.resources.limits.memory`    | memory limit of thehive container  | `512Mi`               |
| `minio.Statefulset.contianers.resources.limits.cpu`       | cpu limit of thehive container     | `500m`                |
| `minio.Statefulset.contianers.resources.requests.cpu`     | min cpu provisioneted by cluster   | `100m`                |
| `minio.Statefulset.contianers.resources.requests.memory`  | min memoru provisioneted by clutes | `100Mi`               |

## Diagram

![](https://res.cloudinary.com/drtwg9pdt/image/upload/v1655287944/diagram_iiqfzr.png "Text to show on mouseover").

## Services

This helm chart will install the following services on the kubernetes cluster:

- **cortex**
- **thehive**
- **minio**

## Install

**To Verify if the templates are correct**:

```bash
helm install elasticsearch ./elasticsearch --values ./elasticsearch/values.yaml -n elasticsearch --create-namespace --dry-run --debug && helm lint
```

```bash
helm install cassandra ./cassandra --values ./cassandra/values.yaml -n cassandra --create-namespace --dry-run --debug && helm lint
```

```bash
helm install thehive ./thehive --values ./thehive/values.yaml -n thehive --create-namespace --dry-run --debug && helm lint
```

**Deploy charts**:

```bash
  helm install elasticsearch ./elasticsearch --values ./elasticsearch/values.yaml -n elasticsearch --create-namespace
```

```bash
  helm install cassandra ./cassandra --values ./cassandra/values.yaml -n cassandra --create-namespace
```

```bash
  helm install thehive ./thehive --values ./thehive/values.yaml -n thehive --create-namespace
```

**Update helm deployment**:

```bash
helm upgrade elasticsearch ./elasticsearch --values ./elasticsearch/values.yaml -n elasticsearch
```

```bash
helm upgrade cassandra ./cassandra --values ./cassandra/values.yaml -n cassandra
```

```bash
helm upgrade thehive ./thehive --values ./thehive/values.yaml -n thehive
```

**Update helm rollback**:

```bash
helm rollback elasticsearch RELEASE_NUMBER -n elasticsearch
```

```bash
helm rollback cassandra RELEASE_NUMBER -n cassandra
```

```bash
helm rollback thehive RELEASE_NUMBER -n thehive
```

**Delete helm deployment**:

```bash
helm uninstall elasticsearch --namespace elasticsearch
```

```bash
helm uninstall cassandra --namespace cassandra
```

```bash
helm uninstall thehive --namespace thehive
```

For more information on using Helm, refer to the [Helm documentation](https://github.com/kubernetes/helm#docs).

## About helm Chart of this project

**Main chart**

- The main chart installing cortex, thehive and minio.

**Dependencies**

- The main chart use elasticsearch and cassandra as dependencies.

**Config**

- Any configuration changes must be made in the values.yml file of the respective charts, currently the 3 values ​​file. One of the main services, one from cassandra and one from elasticsearch.

**Deploy and uninstall time**

- Deploy time is currently 6 min and uninstall time 30 min

## Review Process

For information regarding the review procedure used by chart repository maintainers, see chart maintainers.

## Supported Kubernetes Versions

This chart repository supports the latest and previous minor versions of Kubernetes. For example, if the latest minor release of Kubernetes is 1.24 then 1.23 and 1.22 are supported. Charts may still work on previous versions of Kubernertes even though they are outside the target supported window.

### Update Timeline

| Update                                                 | Status             |
| ------------------------------------------------------ | ------------------ |
| **Refactor helm chart code**                           | :white_check_mark: |
| **Fix connection between application and ES**          | :white_check_mark: |
| **Add configmap for custom settings**                  | :white_check_mark: |
| **Configure persistence for thehive logs**             | :white_check_mark: |
| **Change thehive charge to statefulset**               | :white_check_mark: |
| **Change cortex chart to statefulset**                 | :white_check_mark: |
| **Configure persistence for cortex logs**              | :white_check_mark: |
| **Separate services by namespace**                     | :white_check_mark: |
| **Separate services by namespace**                     | :white_check_mark: |
| **fix documentation and filenames**                    | _**pending**_      |
| **Fix connection between application and Cassandra**   | _**pending**_      |
| **run elasticsearch and cassandra in diferent charts** | _**pending**_      |

Note that this project has been under active development for some time, so you might run into [issues](https://github.com/StrangeBeeCorp/helm-charts/issues). If you do, please don't be shy about letting us know, or better yet, contribute a fix or feature . any doubt you may [reach out](#where-to-find-us).

## Where to Find Us

For general Helm Chart discussions join the room in the [Slack channel](https://ezops.slack.com/archives/C03DH7JBADR).

For issues and support for Helm and Charts see [Support Channels](CONTRIBUTING.md#support-channels).
