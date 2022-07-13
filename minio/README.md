# Minio

## helm charts

The canonical source for Helm charts is the [Helm Hub](https://hub.helm.sh/), an aggregator for distributed chart repos.
For more information about installing and using Helm, see the
[Helm Docs](https://helm.sh/docs/). For a quick introduction to Charts, see the [Chart Guide](https://helm.sh/docs/topics/charts/).

Step by step to install [Quick installation](https://github.com/StrangeBeeCorp/helm-charts/tree/main#install)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

# More About

### [_Minio_](https://docs.min.io/minio/k8s/)

<!-- TODO: CHECK BELOW DOCUMENTATION 21~43 -->
## Important Informations
  ### Storage
  Change the value of TheHiveStorageClass.cloud according to the cloud where the cluster is running.
  ```bash
    helm upgrade minio ./minio --values ./minio/values.yaml -n minio --set TheHiveStorageClass.cloud=google
  ```

  If it is running locally, set this parameter to the value "local".
   
  ```bash
  helm upgrade minio ./minio --values ./minio/values.yaml -n minio --set MinioStorageClass.cloud=local
  ```

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

<!-- ![](https://res.cloudinary.com/drtwg9pdt/image/upload/v1655287944/diagram_iiqfzr.png "Text to show on mouseover"). -->

## Services

This helm chart will install the following services on the kubernetes cluster:

- **minio**

## Install

**To Verify if the templates are correct**:

```bash
helm install minio ./minio --values ./minio/values.yaml -n minio --create-namespace --dry-run --debug && helm lint
```

**Deploy charts**:

```bash
  helm install minio ./minio --values ./minio/values.yaml -n minio --create-namespace
```

**Update helm deployment**:

```bash
helm upgrade minio ./minio --values ./minio/values.yaml -n minio
```

**Update helm rollback**:


```bash
helm rollback minio RELEASE_NUMBER -n minio
```

**Delete helm deployment**:


```bash
helm uninstall minio --namespace minio
```

For more information on using Helm, refer to the [Helm documentation](https://github.com/kubernetes/helm#docs).

## About helm Chart of this project

**Main chart**

- The main chart minio.

**Dependencies**

- minio


**Deploy and uninstall time**

- Deploy time is currently 6 min and uninstall time 2 min

## Review Process

For information regarding the review procedure used by chart repository maintainers, see chart maintainers.

## Supported Kubernetes Versions

This chart repository supports the latest and previous minor versions of Kubernetes. For example, if the latest minor release of Kubernetes is 1.24 then 1.23 and 1.22 are supported. Charts may still work on previous versions of Kubernertes even though they are outside the target supported window.


Note that this project has been under active development for some time, so you might run into [issues](https://github.com/StrangeBeeCorp/helm-charts/issues). If you do, please don't be shy about letting us know, or better yet, contribute a fix or feature . any doubt you may [reach out](#where-to-find-us).
