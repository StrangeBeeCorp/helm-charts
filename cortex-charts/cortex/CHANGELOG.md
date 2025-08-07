## Next release

- Tweak kubeVersion constraints to accept EKS specific versions [#80](https://github.com/StrangeBeeCorp/helm-charts/pull/80) [#81](https://github.com/StrangeBeeCorp/helm-charts/pull/81) by @julienbaladier
- (BREAKING CHANGE) Target [Bitnami Legacy repository](https://github.com/bitnami/charts/issues/35164) for images used in dependency charts [#82](https://github.com/StrangeBeeCorp/helm-charts/pull/82)
- Add missing condition in Ingress template on TLS block [#85](https://github.com/StrangeBeeCorp/helm-charts/pull/85)


## 0.2.0

- Add `deletecollection` permission on jobs to Cortex role [#67](https://github.com/StrangeBeeCorp/helm-charts/pull/67)
- Add correct link to Cortex `v3.2.0` release page in README [#70](https://github.com/StrangeBeeCorp/helm-charts/pull/70)
- Add `logback.xml` optional file to Cortex Deployment [#71](https://github.com/StrangeBeeCorp/helm-charts/pull/71)
- Move Cortex container command flags to env vars in ConfigMap [#72](https://github.com/StrangeBeeCorp/helm-charts/pull/72)
- Update Cortex to v3.2.1-1 [#75](https://github.com/StrangeBeeCorp/helm-charts/pull/75)


## 0.1.0

- Create Cortex Helm Chart [#42](https://github.com/StrangeBeeCorp/helm-charts/pull/42)
