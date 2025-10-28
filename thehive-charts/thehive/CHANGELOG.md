## Next release

- Nothing yet


## 0.4.6

- Update TheHive to v5.5.11-1 [#105](https://github.com/StrangeBeeCorp/helm-charts/pull/105)


## 0.4.5

- Target [Bitnami Legacy repository](https://github.com/bitnami/charts/issues/35164) for remaining images in dependency charts [#102](https://github.com/StrangeBeeCorp/helm-charts/pull/102)


## 0.4.4

- Update TheHive to v5.5.10-1 [#100](https://github.com/StrangeBeeCorp/helm-charts/pull/100)


## 0.4.3

- Update TheHive to v5.5.9-1 [#98](https://github.com/StrangeBeeCorp/helm-charts/pull/98)


## 0.4.2

- Update TheHive to v5.5.8-1 [#96](https://github.com/StrangeBeeCorp/helm-charts/pull/96)


## 0.4.1

- Fix nil pointer when rendering Ingress template [#92](https://github.com/StrangeBeeCorp/helm-charts/pull/92) [#93](https://github.com/StrangeBeeCorp/helm-charts/pull/93) by @hzlnqodrey


## 0.4.0

- (BREAKING CHANGE) Rework labels and annotations in TheHive Helm Chart [#77](https://github.com/StrangeBeeCorp/helm-charts/pull/77)
- (BREAKING CHANGE) Rework TheHive Helm Chart values and resources [#78](https://github.com/StrangeBeeCorp/helm-charts/pull/78)
- Add monitoring configuration [#79](https://github.com/StrangeBeeCorp/helm-charts/pull/79)
- Tweak kubeVersion constraints to accept EKS specific versions [#80](https://github.com/StrangeBeeCorp/helm-charts/pull/80) [#81](https://github.com/StrangeBeeCorp/helm-charts/pull/81) by @julienbaladier
- (BREAKING CHANGE) Target [Bitnami Legacy repository](https://github.com/bitnami/charts/issues/35164) for images used in dependency charts [#82](https://github.com/StrangeBeeCorp/helm-charts/pull/82)
- Update TheHive to v5.5.7-1 and other softwares versions [#83](https://github.com/StrangeBeeCorp/helm-charts/pull/83)


## 0.3.6

- Update TheHive to v5.5.5-1 [#73](https://github.com/StrangeBeeCorp/helm-charts/pull/73)


## 0.3.5

- Update TheHive to v5.5.4-1 [#68](https://github.com/StrangeBeeCorp/helm-charts/pull/68)


## 0.3.4

- Update TheHive to v5.5.3-1 [#64](https://github.com/StrangeBeeCorp/helm-charts/pull/64)


## 0.3.3

- Move TheHive Helm Chart instructions to StrangeBee doc [#61](https://github.com/StrangeBeeCorp/helm-charts/pull/61)
- Update TheHive to v5.5.2-1 [#62](https://github.com/StrangeBeeCorp/helm-charts/pull/62)


## 0.3.2

- Update TheHive to v5.5.1-1 [#59](https://github.com/StrangeBeeCorp/helm-charts/pull/59)


## 0.3.1

- Add config to tweak TheHive Deployment strategy [#53](https://github.com/StrangeBeeCorp/helm-charts/pull/53)
- Add missing selector labels in TheHive Pekko config [#54](https://github.com/StrangeBeeCorp/helm-charts/pull/54)
- Move TheHive parameters from command flags to env vars in ConfigMap [#55](https://github.com/StrangeBeeCorp/helm-charts/pull/55)
- Add "logback.xml" optional file in ConfigMap [#56](https://github.com/StrangeBeeCorp/helm-charts/pull/56)
- Update TheHive to v5.5.0-1 and other softwares versions [#57](https://github.com/StrangeBeeCorp/helm-charts/pull/57)


## 0.3.0

- Improve subchart services hostnames handling [#43](https://github.com/StrangeBeeCorp/helm-charts/pull/43)
- Create dedicated templates for TheHive Role and RoleBinding manifests [#44](https://github.com/StrangeBeeCorp/helm-charts/pull/44)
- (BREAKING CHANGE) Change initContainers config and values [#45](https://github.com/StrangeBeeCorp/helm-charts/pull/45)
- Add parameters in TheHive values.yaml to configure Cortex servers [#46](https://github.com/StrangeBeeCorp/helm-charts/pull/46)
- Fix regressions introduced in #44 and #45 [#47](https://github.com/StrangeBeeCorp/helm-charts/pull/47)
- Add probe configs and update TheHive healthcheck route [#48](https://github.com/StrangeBeeCorp/helm-charts/pull/48)
- (BREAKING CHANGE) Add "thehive" root key and rename application.conf variable [#49](https://github.com/StrangeBeeCorp/helm-charts/pull/49)
- Update README and values.yaml comments [#50](https://github.com/StrangeBeeCorp/helm-charts/pull/50)
- Update TheHive to v5.4.9-1 and other softwares versions [#51](https://github.com/StrangeBeeCorp/helm-charts/pull/51)


## 0.2.2

- Update TheHive version from 5.4.7-1 to 5.4.8-1 [#37](https://github.com/StrangeBeeCorp/helm-charts/pull/37)
- Add cluster domain configuration [#38](https://github.com/StrangeBeeCorp/helm-charts/pull/38)
- Reorganize charts folders [#39](https://github.com/StrangeBeeCorp/helm-charts/pull/39)
- Update "helm/chart-releaser-action" from v1.6.0 to v1.7.0 [#40](https://github.com/StrangeBeeCorp/helm-charts/pull/40)


## 0.2.1

- Fix TheHive crashLoop on first start using a startupProbe [#31](https://github.com/StrangeBeeCorp/helm-charts/pull/31)
- Fix the CM template used to create a custom "application.conf" file [#32](https://github.com/StrangeBeeCorp/helm-charts/pull/32)
- Update TheHive Helm Chart README [#33](https://github.com/StrangeBeeCorp/helm-charts/pull/33)
- Update TheHive softwares versions [#34](https://github.com/StrangeBeeCorp/helm-charts/pull/34)


## 0.2.0

- Replace ElasticSearch unmaintained Helm Chart [#19](https://github.com/StrangeBeeCorp/helm-charts/pull/19)
- Use Bitnami Cassandra Helm Chart [#20](https://github.com/StrangeBeeCorp/helm-charts/pull/20)
- Use MinIO (community) Helm Chart [#21](https://github.com/StrangeBeeCorp/helm-charts/pull/21)
- Rework GitHub workflow [#22](https://github.com/StrangeBeeCorp/helm-charts/pull/22)
- Remove Helm Chart tests and NOTES.txt [#23](https://github.com/StrangeBeeCorp/helm-charts/pull/23)
- Update READMEs and ArtifactHub information [#24](https://github.com/StrangeBeeCorp/helm-charts/pull/24)
- Add Secret and improve ConfigMaps usage [#25](https://github.com/StrangeBeeCorp/helm-charts/pull/25)
- Tweak subcharts configurations [#26](https://github.com/StrangeBeeCorp/helm-charts/pull/26)
- Improve default values for production use [#27](https://github.com/StrangeBeeCorp/helm-charts/pull/27)
- Fix MinIO bucket configuration [#28](https://github.com/StrangeBeeCorp/helm-charts/pull/28)
- Fix ConfigMap mount to prevent overwriting files in "/etc/thehive" folder [#29](https://github.com/StrangeBeeCorp/helm-charts/pull/29)


## 0.1.7

- Clean and improve repository structure [#13](https://github.com/StrangeBeeCorp/helm-charts/pull/13)
- Fix Cassandra OOM crashloop [#14](https://github.com/StrangeBeeCorp/helm-charts/pull/14)
- Fix akka pod discovery [#15](https://github.com/StrangeBeeCorp/helm-charts/pull/15)
- Update and pin images versions [#16](https://github.com/StrangeBeeCorp/helm-charts/pull/16)
- Update TheHive's README [#17](https://github.com/StrangeBeeCorp/helm-charts/pull/17)
