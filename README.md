# The Hive

## helm charts
The canonical source for Helm charts is the [Helm Hub](https://hub.helm.sh/), an aggregator for distributed chart repos.
For more information about installing and using Helm, see the
[Helm Docs](https://helm.sh/docs/). For a quick introduction to Charts, see the [Chart Guide](https://helm.sh/docs/topics/charts/).


Step by step to install [Quick installation](https://github.com/StrangeBeeCorp/helm-charts/tree/main#install)

## Diagram
![](https://res.cloudinary.com/drtwg9pdt/image/upload/v1655287944/diagram_iiqfzr.png "Text to show on mouseover").

## Services

This helm chart will install the following services on the kubernetes cluster:

- **cortex**
- **hive**
- **minio**
- **elasticserach**
- **cassandra**

### Update Timeline

| Update                                                      | Status             |
| ----------------------------------------------------------- | ------------------ |
| **Refactor helm chart code**                                | :white_check_mark: |
| **Fix connection between application and ES and Cassandra** | :white_check_mark: |
| **Add configmap for custom settings**                       | :white_check_mark: |
| **Configure persistence for hive logs**                     | **review**         |
| **Change hive charge to statefulset**                       | **review**         |
| **Change cortex chart to statefulset**                      | **review**         |
| **Configure persistence for cortex logs**                   | **review**         |
| **Separate services by namespace**                          | _pending_          |

Note that this project has been under active development for some time, so you might run into [issues](https://github.com/StrangeBeeCorp/helm-charts/issues). If you do, please don't be shy about letting us know, or better yet, contribute a fix or feature . any doubt you may [reach out](#where-to-find-us).

## Where to Find Us

For general Helm Chart discussions join the room in the [Slack channel](https://ezops.slack.com/archives/C03DH7JBADR).

For issues and support for Helm and Charts see [Support Channels](CONTRIBUTING.md#support-channels).

## Install

**To Verify if the templates are correct**:

```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace --dry-run --debug && helm lint
```

**Deploy chart**:

```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace
```

**Update helm deployment**:

```bash
helm upgrade thehive ./ --values values.yaml -n thehive
```

**Update helm rollback**:

```bash
helm rollback thehive RELEASE_NUMBER -n thehive 
```

**Delete helm deployment**:

```bash
helm uninstall thehive --namespace thehive
```

For more information on using Helm, refer to the [Helm documentation](https://github.com/kubernetes/helm#docs).

## About helm Chart of this project

**Main chart**
- The main chart installing cortex, hive and minio.

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
