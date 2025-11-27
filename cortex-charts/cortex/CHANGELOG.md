## Next release

- Nothing yet

## 1.0.0

- Set all replicas to 1 by default [#110](https://github.com/StrangeBeeCorp/helm-charts/pull/110)
- Fix the env var providing the HTTP secret to Cortex [#112](https://github.com/StrangeBeeCorp/helm-charts/pull/112)
- Configure Cortex to actually use provided ElasticSearch credentials [#113](https://github.com/StrangeBeeCorp/helm-charts/pull/113)
- Implement authenticated API call to ElasticSearch for the init-container [#114](https://github.com/StrangeBeeCorp/helm-charts/pull/114)
- (BREAKING CHANGE) Update Cortex to v4.0.0-1 and ElasticSearch to v8.18.0 along with other dependencies [#116](https://github.com/StrangeBeeCorp/helm-charts/pull/116)
- Increase resources for Cortex HTTP parser [#120](https://github.com/StrangeBeeCorp/helm-charts/pull/120)
- Add Helm documentation for `cortex` chart in `helm-docs` format [#121](https://github.com/StrangeBeeCorp/helm-charts/pull/121)

## 0.3.3

- Add HTTPS option for the init-container checking ElasticSearch availability [#107](https://github.com/StrangeBeeCorp/helm-charts/pull/107)

## 0.3.2

- Target [Bitnami Legacy repository](https://github.com/bitnami/charts/issues/35164) for remaining images in dependency charts [#102](https://github.com/StrangeBeeCorp/helm-charts/pull/102)

## 0.3.1

- fix(cortex helm): nil pointer when rendering ingress [#91](https://github.com/StrangeBeeCorp/helm-charts/pull/91) by @julienbaladier

## 0.3.0

- Tweak kubeVersion constraints to accept EKS specific versions [#80](https://github.com/StrangeBeeCorp/helm-charts/pull/80) [#81](https://github.com/StrangeBeeCorp/helm-charts/pull/81) by @julienbaladier
- (BREAKING CHANGE) Target [Bitnami Legacy repository](https://github.com/bitnami/charts/issues/35164) for images used in dependency charts [#82](https://github.com/StrangeBeeCorp/helm-charts/pull/82)
- Add missing condition in Ingress template on TLS block [#85](https://github.com/StrangeBeeCorp/helm-charts/pull/85)
- (BREAKING CHANGE) Improve annotations and labels management [#86](https://github.com/StrangeBeeCorp/helm-charts/pull/86)
- Improve configuration options for Deployment probes [#87](https://github.com/StrangeBeeCorp/helm-charts/pull/87)
- Use new download links for analyzers and responders configuration [#88](https://github.com/StrangeBeeCorp/helm-charts/pull/88)
- Update bitnami/elasticsearch dependency chart [#89](https://github.com/StrangeBeeCorp/helm-charts/pull/89)

## 0.2.0

- Add `deletecollection` permission on jobs to Cortex role [#67](https://github.com/StrangeBeeCorp/helm-charts/pull/67)
- Add correct link to Cortex `v3.2.0` release page in README [#70](https://github.com/StrangeBeeCorp/helm-charts/pull/70)
- Add `logback.xml` optional file to Cortex Deployment [#71](https://github.com/StrangeBeeCorp/helm-charts/pull/71)
- Move Cortex container command flags to env vars in ConfigMap [#72](https://github.com/StrangeBeeCorp/helm-charts/pull/72)
- Update Cortex to v3.2.1-1 [#75](https://github.com/StrangeBeeCorp/helm-charts/pull/75)

## 0.1.0

- Create Cortex Helm Chart [#42](https://github.com/StrangeBeeCorp/helm-charts/pull/42)
