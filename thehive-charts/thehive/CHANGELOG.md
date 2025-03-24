## Next release

- Improve subchart services hostnames handling [#43](https://github.com/StrangeBeeCorp/helm-charts/pull/43)
- Create dedicated templates for TheHive Role and RoleBinding manifests [#44](https://github.com/StrangeBeeCorp/helm-charts/pull/44)
- (BREAKING CHANGE) Change initContainers config and values [#45](https://github.com/StrangeBeeCorp/helm-charts/pull/45)
- Add parameters in TheHive values.yaml to configure Cortex servers [#46](https://github.com/StrangeBeeCorp/helm-charts/pull/46)
- Fix regressions introduced in [#44](https://github.com/StrangeBeeCorp/helm-charts/pull/44) and [#45](https://github.com/StrangeBeeCorp/helm-charts/pull/45) [#47](https://github.com/StrangeBeeCorp/helm-charts/pull/47)


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
