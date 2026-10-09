# thehive-flow

[![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ](https://github.com/StrangeBeeCorp/helm-charts/releases) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![AppVersion: 6.0.0-4-rc1](https://img.shields.io/badge/AppVersion-6.0.0--4--rc1-informational?style=flat-square)

## Description

TheHive Flow — TheHive Orchestration engine, running playbooks as durable Temporal workflows.

A single `helm install` brings up the TheHive Flow app **and** a bundled Temporal Server. PostgreSQL and an S3-compatible object store are external: provision them before installing, and point the chart at them with `postgresql.*` and `blobstore.*`.

## Upgrading

`config.api.public.url` is required while `config.api.public.enable` is true: `helm upgrade` with values that do not set it refuses to render. Set it to the public URL at which clients reach TheHive Flow's root.

## Codex execution backend

- **Kubernetes (default).** With `codex.backend: kubernetes`, each playbook script runs as a short-lived Kubernetes Job in a dedicated `<release-namespace>-jobs` namespace (derived from the install namespace, not the release name) — no Docker required. The chart provisions the namespace, RBAC, and object-store credentials; the assistant image (`codex.kubernetes.assistantImage`) and the language images must be pullable by the cluster (use `codex.languageImages` to repoint them at an internal registry for air-gapped clusters).
- **Docker (opt-in).** Set `codex.backend: docker` to run scripts in short-lived Docker containers instead. This needs a reachable Docker endpoint: on nodes that expose a Docker socket (kind, Docker Desktop) enable `dockerSocketProxy`; on containerd/CRI-O clusters (e.g. EKS/Bottlerocket, which have no Docker socket) point `codex.dockerHost` at an external Docker daemon.

**Homepage:** <https://strangebee.com/thehive/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| StrangeBee |  | <https://strangebee.com/> |

## Source Code

* <https://github.com/StrangeBeeCorp/helm-charts/tree/main/thehive-charts/thehive-flow>

## Requirements

Kubernetes: `>=1.29.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://temporalio.github.io/helm-charts | temporal | 1.7.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity for the TheHive Flow pod. |
| blobstore.backend | string | `"s3"` | Backend: "s3" (durable). "memory" is unit-test-only and rejected at startup (the chart fails the render). |
| blobstore.s3.accessKeyId | string | `"thehive-flow"` | Access key ID (static creds). Empty → AWS SDK default chain (IRSA / Pod Identity). For the bundled SeaweedFS, must match its admin.accessKey and the bootstrap Secret's AWS_ACCESS_KEY_ID. |
| blobstore.s3.bucket | string | `"thehive-flow"` | Bucket for blobs. |
| blobstore.s3.endpoint | string | `"http://s3-store-all-in-one.soar.svc.cluster.local:8333"` | S3 endpoint URL. Empty for AWS S3 (SDK resolves it); set to your S3-compatible endpoint otherwise. Default targets the bundled SeaweedFS in `soar`; set it for another namespace or store. Must be a cross-namespace FQDN when codex.backend: kubernetes — it is passed verbatim to the assistant containers, which run in jobNamespace and cannot resolve a bare Service name. |
| blobstore.s3.region | string | `"us-east-1"` | Region. Some gateways ignore it, but the AWS SDK requires a value. |
| blobstore.s3.usePathStyle | bool | `true` | Path-style addressing. true for most S3-compatible gateways; false for AWS S3 (virtual-hosted). |
| codex.backend | string | `"kubernetes"` | Execution backend for Codex scripts: "kubernetes" (default; each script runs as an isolated Job) or "docker" (needs a Docker socket — see dockerSocketProxy / codex.dockerHost). |
| codex.dockerHost | string | `""` | DOCKER_HOST for the docker backend. Empty + dockerSocketProxy.enabled auto-wires the proxy. Ignored when backend is kubernetes. |
| codex.kubernetes.activeDeadlineSeconds | int | `0` | Cap a Job's total run time in seconds (0 → backend default). |
| codex.kubernetes.assistantImage.repository | string | `"docker.io/strangebee/thehive-flow-assistant"` | Assistant init/sidecar image repository (moves blobs between S3 and the Job work dir). |
| codex.kubernetes.assistantImage.tag | string | `""` | Image tag. Empty falls back to .Chart.AppVersion. |
| codex.kubernetes.ephemeralStorage | string | `""` | Cap the shared work-dir emptyDir (e.g. "1Gi"); empty = uncapped. |
| codex.kubernetes.gracePeriodSeconds | int | `0` | Pod terminationGracePeriodSeconds for output promotion (0 → backend default). |
| codex.kubernetes.imagePullSecrets | list | `[]` | imagePullSecrets (existing Secret names) for the assistant + language images. These Secrets must exist in the Job namespace (jobNamespace), which is separate from the release namespace — imagePullSecrets are namespace-scoped. |
| codex.kubernetes.jobNamespace | string | `""` | Namespace for Codex Jobs. Empty defaults to "<release-namespace>-jobs". |
| codex.kubernetes.nodeSelector | list | `[]` | nodeSelector for Job pods, as "key=value" strings. |
| codex.kubernetes.objectStoreSecret | string | `""` | Existing Secret with AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY for the assistant's static S3 access, resolved in the Job namespace (jobNamespace). Behaviour when empty:   - static credentials (blobstore.s3.accessKeyId set): defaults to the blobstore Secret name     (secrets.s3SecretAccessKey.existingSecret), copied into the Job namespace when rbac.create;   - ambient credentials (accessKeyId unset): omitted entirely, so the assistant uses the AWS SDK     default credential chain via serviceAccountAnnotations (IRSA / Pod Identity). A custom name must be provisioned in the Job namespace yourself. |
| codex.kubernetes.rbac.create | bool | `true` | Create the Job namespace, the codex-jobs ServiceAccount, and the Roles/RoleBindings (thehive-flow → drive Jobs; codex-jobs → patch own pod). Disable to manage them yourself. |
| codex.kubernetes.resources | object | `{}` | Default CPU/memory requests+limits for the user (script) container. |
| codex.kubernetes.serviceAccount | string | `"codex-jobs"` | ServiceAccount the Job pods run as (created when rbac.create). |
| codex.kubernetes.serviceAccountAnnotations | object | `{}` | Annotations on the codex-jobs ServiceAccount (e.g. eks.amazonaws.com/role-arn for IRSA), so Codex Jobs can use ambient S3 credentials (AWS SDK default chain) when objectStoreSecret is unset. |
| codex.kubernetes.ttlSecondsAfterFinished | int | `0` | Auto-delete finished Jobs after N seconds (0 → backend default). |
| codex.languageImages | object | `{}` | Override the container image for built-in Codex languages, keyed by language name (e.g. "python@v3_11", "javascript@v24"). Point these at your internal registry for air-gapped / proxied clusters that cannot reach the default gcr.io images. Empty uses the built-in defaults. Applies to both backends (kubernetes and docker). |
| config.api.public.addr | string | `"0.0.0.0:8081"` | Bind address for the REST API listener. |
| config.api.public.enable | bool | `true` | Enable the REST API listener. |
| config.api.public.trusted_proxies | list | `[]` | Trusted proxy CIDRs: for a request from one of them, the webhook rate limit (`rate_limit_per_minute`) reads the client from X-Forwarded-For. A malformed CIDR (including a bare IP), an IPv4-mapped CIDR or a /0 fails startup. A range that also holds clients lets them bypass that limit, as the pod CIDR does behind an in-cluster ingress. A trusted proxy must append the address of its own peer to X-Forwarded-For. |
| config.api.public.url | string | `""` | Required when enable is true. Public URL: absolute http(s), no credentials, query or fragment; webhook responses carry `<url>/webhook/<id>`. |
| config.modules.observability.listener.addr | string | `"0.0.0.0:9090"` | Bind address for the observability listener (livez/readyz/metrics). |
| config.modules.observability.metrics.prometheus.enabled | bool | `true` | Expose Prometheus metrics on the observability listener. |
| config.modules.observability.pprof.enabled | bool | `false` | Expose pprof endpoints on the observability listener. |
| config.modules.runs.retention | string | `"168h"` | Run retention. TheHive Flow is the source of truth for retention. |
| config.modules.runs.syncTemporalRetention | string | `nil` | Sync the Temporal namespace retention to runs.retention (TheHive Flow becomes the source of truth). Null (default) follows temporal.enabled — on for the bundled Temporal, off for an external one: rewriting the retention of a namespace owned by another team would silently delete their workflow histories. Set true/false to force. |
| config.modules.workers.activities.egress.allowlist | list | `[]` | Outbound connections from workflow nodes (http, integration, llm.chat) are guarded against SSRF: non-public addresses (loopback, RFC1918, link-local, CGNAT, reserved) are blocked at dial time with "egress guard: outbound connection to non-public address blocked". To reach a legitimate internal target (TheHive or Cortex on a private network, a locally hosted LLM provider), allowlist its CIDR range. A malformed CIDR (including a bare IP without prefix) fails startup. |
| config.modules.workers.activities.http.request_logging | bool | `false` | Log every HTTP activity request. |
| config.modules.workers.activities.mailer.from | string | `""` | Default sender address. |
| config.modules.workers.activities.mailer.host | string | `""` | SMTP server. Empty keeps the configuration pushed by TheHive; set, it overrides it. |
| config.modules.workers.activities.mailer.port | int | `587` | SMTP port, 1–65535. |
| config.modules.workers.activities.mailer.tls | bool | `true` | STARTTLS, the only TLS the mailer speaks (no implicit TLS, so not port 465). Required to send credentials to a non-loopback host. |
| config.modules.workers.activities.mailer.user | string | `""` | SMTP username. Its password comes from secrets.mailerPassword. |
| config.modules.workers.activities.thehive.url | string | `"http://thehive:9000"` | TheHive URL (assumes a Service named `thehive` in the namespace). |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container-level securityContext for the TheHive Flow container. |
| dockerSocketProxy.enabled | bool | `false` | Deploy the embedded docker-socket-proxy. Off by default. |
| dockerSocketProxy.hostSocketPath | string | `"/var/run/docker.sock"` | Path to the Docker socket on the node, hostPath-mounted read-only into the proxy. |
| dockerSocketProxy.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dockerSocketProxy.image.repository | string | `"docker.io/tecnativa/docker-socket-proxy"` | Container image repository for the docker socket proxy. |
| dockerSocketProxy.image.tag | string | `"v0.5.0@sha256:1f5038b54f06c3e18422902cf00ba21803d1c97805aae032e5e6673d532d3459"` | Image tag. |
| dockerSocketProxy.permissions | object | `{"CONTAINERS":1,"IMAGES":1,"INFO":1,"NETWORKS":1,"POST":1,"VOLUMES":1}` | Docker API verbs the proxy forwards (1 = allow, 0 = deny). |
| dockerSocketProxy.resources | object | `{"limits":{"memory":"64Mi"},"requests":{"cpu":"10m","memory":"32Mi"}}` | Resource requests/limits for the proxy pod. |
| dockerSocketProxy.service.port | int | `2375` | Service port (and container port). |
| dockerSocketProxy.service.type | string | `"ClusterIP"` | Service type for the proxy. |
| externalTemporal.host | string | `""` | External Temporal frontend host. Only used when `temporal.enabled: false`. Must be a plaintext, unauthenticated Temporal frontend reachable in-cluster or over a private network (VPC/peering): TLS/mTLS and API keys are not supported, so Temporal Cloud will not work. |
| externalTemporal.port | int | `7233` | External Temporal frontend port. |
| fullnameOverride | string | `""` | Override the entire fullname. |
| goMemLimit | string | `""` | Explicit GOMEMLIMIT for the TheHive Flow container. Empty derives it from `resources.limits.memory` (see goMemLimitPercent). Only Go's binary suffixes are accepted — B, KiB, MiB, GiB, TiB, or a plain byte count. "900MB" is NOT one of them and makes the container exit at startup with `fatal error: malformed GOMEMLIMIT`. |
| goMemLimitPercent | int | `85` | Percentage of `resources.limits.memory` used as GOMEMLIMIT when goMemLimit is empty. 0 leaves GOMEMLIMIT unset; anything at or above 100 fails the render (it would leave no margin at all). Go's GC does not read the cgroup ceiling on its own, so without a value the pod is OOMKilled with the collector still idle. The margin the percentage leaves must be at least 128 MiB in absolute terms — GOMEMLIMIT bounds runtime-managed memory only, so the mapped binary (90 MiB in the shipped image) and kernel-held memory come out of it, and that cost does not shrink with the limit. 85% of the default 1Gi leaves 154 MiB; on a 512Mi limit it would leave 77 MiB and the render fails, telling you to lower this value (75% fits). |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"docker.io/strangebee/thehive-flow"` | TheHive Flow container image repository. |
| image.tag | string | `""` | Image tag. Empty falls back to `.Chart.AppVersion`. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| migrations.enabled | bool | `true` | Enable the pre-install/pre-upgrade `beeflow migrate up` Job. |
| migrations.goMemLimitPercent | int | `50` | Percentage of this Job's `resources.limits.memory` used as its GOMEMLIMIT. 50, not the server's 85: the same 128 MiB of margin has to come out of a 256Mi limit rather than 1Gi, so the percentage that satisfies it is necessarily lower. Raise `resources.limits.memory` below if you need a higher share. 0 opts out. |
| migrations.resources | object | `{"limits":{"ephemeral-storage":"256Mi","memory":"256Mi"},"requests":{"cpu":"100m","ephemeral-storage":"128Mi","memory":"128Mi"}}` | Resource requests/limits for the migration Job's pod. `limits.memory` is also what this Job's GOMEMLIMIT is derived from. |
| nameOverride | string | `""` | Override the chart name portion of the fullname. |
| nodeSelector | object | `{}` | nodeSelector for the TheHive Flow pod. |
| observability.otlp.endpoint | string | `""` | OTLP exporter endpoint (e.g. http://otel-collector:4317). |
| observability.otlp.headers | string | `""` | OTLP exporter headers (comma-separated key=value). |
| observability.otlp.protocol | string | `""` | OTLP protocol — grpc or http/protobuf. |
| observability.otlp.resourceAttributes | string | `""` | Resource attributes for emitted spans/metrics (comma-separated key=value). |
| podAnnotations | object | `{}` | Extra annotations on the TheHive Flow pod. |
| podLabels | object | `{}` | Extra labels on the TheHive Flow pod. |
| podSecurityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod-level securityContext. UID 65532 is the distroless nonroot user. |
| postgresql.database | string | `"thehive_flow"` | Database name (created by the external Database). |
| postgresql.host | string | `"thehive-flow-postgresql-rw"` | CNPG read-write Service of the external Postgres primary. When temporal.enabled, this must match temporal.server.config.persistence.datastores.{default,visibility}.sql.connectAddr (the bundled Temporal shares this Postgres); the chart fails the render if they diverge. |
| postgresql.port | int | `5432` | Postgres port. |
| postgresql.sslMode | string | `"require"` | SSL mode for the Postgres connection. Defaults to `require` (encrypts in-transit). For the strongest guarantee use `verify-full` and supply the server CA to the client (sslrootcert). |
| postgresql.username | string | `"thehive_flow"` | Postgres role used by the TheHive Flow binary. |
| probes.liveness | object | `{"failureThreshold":3,"httpGet":{"path":"/livez","port":"observability"},"initialDelaySeconds":0,"periodSeconds":10}` | Liveness probe spec. |
| probes.readiness | object | `{"failureThreshold":3,"httpGet":{"path":"/readyz","port":"observability"},"initialDelaySeconds":0,"periodSeconds":5}` | Readiness probe spec. |
| probes.startup | object | `{"failureThreshold":60,"httpGet":{"path":"/livez","port":"observability"},"initialDelaySeconds":0,"periodSeconds":5}` | Startup probe spec. Holds liveness/readiness until the app first serves /livez, so a slow first boot (e.g. pod self-migration when the migration Job is disabled) can't be killed by liveness. Set to {} to disable. |
| replicaCount | int | `1` | Replica count. v1 is single-replica only. |
| resources | object | `{"limits":{"ephemeral-storage":"1Gi","memory":"1Gi"},"requests":{"cpu":"250m","ephemeral-storage":"256Mi","memory":"512Mi"}}` | Resource requests/limits for the TheHive Flow container. `limits.memory` is also what GOMEMLIMIT is derived from — raising it raises GOMEMLIMIT with it, unless goMemLimit pins an explicit value. |
| secrets.databasePassword.existingSecret | string | `"thehive-flow-postgresql-thehive-flow-user"` | Existing Secret holding the TheHive Flow Postgres user's password. |
| secrets.databasePassword.key | string | `"password"` | Key inside the Secret. |
| secrets.jwtSymmetricKey.existingSecret | string | `"thehive-flow-jwt"` | Existing Secret holding the JWT signing key; at least 32 bytes or TheHive Flow refuses to start. |
| secrets.jwtSymmetricKey.key | string | `"jwt-symmetric-key"` | Key inside the Secret. |
| secrets.mailerPassword.existingSecret | string | `""` | Existing Secret holding the SMTP password of config.modules.workers.activities.mailer. Required when mailer.user is set, refused without it. |
| secrets.mailerPassword.key | string | `"password"` | Key inside the Secret. |
| secrets.s3SecretAccessKey.existingSecret | string | `"thehive-flow-s3"` | Existing Secret holding the S3 secret access key (blobstore.backend: s3). The same Secret is reused by the Codex kubernetes backend (object_store_secret), so it carries AWS-standard keys (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY). |
| secrets.s3SecretAccessKey.key | string | `"AWS_SECRET_ACCESS_KEY"` | Key inside the Secret holding the S3 secret access key. |
| secrets.thehiveApiKey.existingSecret | string | `"thehive-flow-thehive"` | Existing Secret holding the TheHive API key. |
| secrets.thehiveApiKey.key | string | `"api-key"` | Key inside the Secret. |
| service.api.port | int | `8081` | Service port for the REST API listener (container port 8081). |
| service.api.type | string | `"ClusterIP"` | Service type for the REST API listener. |
| serviceAccount.annotations | object | `{}` | Annotations on the ServiceAccount (e.g. eks.amazonaws.com/role-arn for IRSA). |
| serviceAccount.automountServiceAccountToken | bool | `false` | Mount the ServiceAccount token into the pod. Forced on when codex.backend is "kubernetes" (the TheHive Flow in-cluster k8s client needs the token). |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount. |
| serviceAccount.name | string | `""` | Override the ServiceAccount name. Empty = generated from fullname. |
| temporal.admintools.resources | object | `{"limits":{"memory":"256Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | Resource requests/limits for the admin-tools pod (ops CLI, mostly idle). |
| temporal.enabled | bool | `true` | Toggle the Temporal subchart. False → use `externalTemporal` below. |
| temporal.schema.useHelmHooks | bool | `true` | Run schema-init as a pre-install/pre-upgrade hook (avoids first-install server crashloops). |
| temporal.server.config.namespaces.create | bool | `true` | Auto-create the listed namespaces post-install (required by registerSearchAttributes). |
| temporal.server.config.namespaces.namespace | list | `[{"name":"default","retention":"168h"}]` | Namespaces to auto-create. |
| temporal.server.config.namespaces.namespace[0] | object | `{"name":"default","retention":"168h"}` | Namespace name. |
| temporal.server.config.namespaces.namespace[0].retention | string | `"168h"` | Workflow execution retention. |
| temporal.server.config.namespaces.useHelmHooks | bool | `false` | Create the namespaces with a plain Job rather than a post-install hook. Subchart 1.7.0 flipped this default to true, which deadlocks the install: the TheHive Flow Deployment's wait-temporal init container blocks until the namespace exists, `helm install --wait` blocks until that Deployment is Available, and a post-install hook only runs once that wait returns. A plain Job runs alongside the Deployment, which is what 1.6.0 did. |
| temporal.server.config.persistence.datastores.default.sql.connectAddr | string | `"thehive-flow-postgresql-rw:5432"` | Service of the external Postgres primary. |
| temporal.server.config.persistence.datastores.default.sql.connectProtocol | string | `"tcp"` | Connection protocol. |
| temporal.server.config.persistence.datastores.default.sql.databaseName | string | `"temporal"` | Workflow-state database name. |
| temporal.server.config.persistence.datastores.default.sql.existingSecret | string | `"thehive-flow-postgresql-temporal-user"` | Existing Secret holding the temporal user's password. |
| temporal.server.config.persistence.datastores.default.sql.maxConnLifetime | string | `"1h"` | Connection lifetime. |
| temporal.server.config.persistence.datastores.default.sql.maxConns | int | `20` | Max open connections. |
| temporal.server.config.persistence.datastores.default.sql.maxIdleConns | int | `20` | Max idle connections. |
| temporal.server.config.persistence.datastores.default.sql.pluginName | string | `"postgres12"` | Temporal SQL plugin (postgres12 works against any modern Postgres). |
| temporal.server.config.persistence.datastores.default.sql.secretKey | string | `"password"` | Key inside the Secret. |
| temporal.server.config.persistence.datastores.default.sql.user | string | `"temporal"` | Postgres role. |
| temporal.server.config.persistence.datastores.visibility.sql.connectAddr | string | `"thehive-flow-postgresql-rw:5432"` | Same primary as the default datastore. |
| temporal.server.config.persistence.datastores.visibility.sql.connectProtocol | string | `"tcp"` | See default.sql.connectProtocol. |
| temporal.server.config.persistence.datastores.visibility.sql.databaseName | string | `"temporal_visibility"` | Visibility-store database name. |
| temporal.server.config.persistence.datastores.visibility.sql.existingSecret | string | `"thehive-flow-postgresql-temporal-user"` | Same external Secret. |
| temporal.server.config.persistence.datastores.visibility.sql.maxConnLifetime | string | `"1h"` | Connection lifetime. |
| temporal.server.config.persistence.datastores.visibility.sql.maxConns | int | `10` | Max open connections for visibility traffic. |
| temporal.server.config.persistence.datastores.visibility.sql.maxIdleConns | int | `10` | Max idle connections for visibility traffic. |
| temporal.server.config.persistence.datastores.visibility.sql.pluginName | string | `"postgres12"` | See default.sql.pluginName. |
| temporal.server.config.persistence.datastores.visibility.sql.secretKey | string | `"password"` | Same Secret key. |
| temporal.server.config.persistence.datastores.visibility.sql.user | string | `"temporal"` | Same role. |
| temporal.server.config.persistence.defaultStore | string | `"default"` | Datastore name used for workflow state. |
| temporal.server.config.persistence.numHistoryShards | int | `512` | Temporal history shards. IMMUTABLE for the cluster's lifetime — it cannot be changed after the first install without recreating Temporal's databases. 512 is a sane production default (harmless for dev); lower it only for a throwaway cluster. |
| temporal.server.config.persistence.visibilityStore | string | `"visibility"` | Datastore name used for the visibility store. |
| temporal.server.frontend.resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests/limits for the frontend. |
| temporal.server.history.resources | object | `{"limits":{"memory":"1Gi"},"requests":{"cpu":"200m","memory":"512Mi"}}` | Resource requests/limits for the history service. Largest share: it caches workflow histories across `numHistoryShards`. |
| temporal.server.matching.resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests/limits for the matching service. |
| temporal.server.worker.resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests/limits for the system worker. |
| temporal.web | object | `{"enabled":false}` | Disable the bundled Temporal Web UI. |
| temporalReadiness.enabled | bool | `true` | Gate the wait-temporal init container. Disable to skip the readiness wait when Temporal is already ready or reachable by other means. |
| temporalReadiness.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| temporalReadiness.image.repository | string | `"docker.io/temporalio/admin-tools"` | Admin-tools image (ships the `temporal` CLI). Pin to match your Temporal server version. |
| temporalReadiness.image.tag | string | `"1.32.1@sha256:9ef0dc5b063bf4ffd5c1512de72e0e73e225bd2c7006a18ce69bd592a8862a83"` | Image tag. |
| temporalReadiness.namespace | string | `"default"` | Temporal namespace to wait for (the namespace TheHive Flow uses). |
| temporalReadiness.resources | object | `{"limits":{"ephemeral-storage":"32Mi","memory":"64Mi"},"requests":{"cpu":"10m","ephemeral-storage":"16Mi","memory":"32Mi"}}` | Resource requests/limits for the wait-temporal init container. |
| terminationGracePeriodSeconds | int | `30` | Grace period the kubelet grants the TheHive Flow pod on SIGTERM before SIGKILL. 30 is Kubernetes' own default, made explicit here because it is paired with an application setting: `shutdown.timeout` (20s by default, warned about above 25s) plus a separate ~5s telemetry flush. Raising `shutdown.timeout` past 25s means raising this too, or the drain is cut short by SIGKILL. |
| tests.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| tests.image.repository | string | `"docker.io/curlimages/curl"` | Image used by the `helm test` probe pod (needs curl). |
| tests.image.tag | string | `"8.22.0@sha256:58adaa4e8dca9c988bae2aba4ab3434a0bb2da16bbe3f92dec39ec7785166777"` | Image tag. |
| tolerations | list | `[]` | tolerations for the TheHive Flow pod. |
| waitContainers.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| waitContainers.image.repository | string | `"docker.io/library/busybox"` | Image repository (needs `sh` and `nc`). Repoint it for air-gapped or private registries. |
| waitContainers.image.tag | string | `"1.38.0@sha256:fd7dc98638c8e305f4dc34e979f1c0fdfdcaeb0fbf8fcff77ae834b6da3d7e6e"` | Image tag. |
| waitContainers.resources | object | `{"limits":{"ephemeral-storage":"32Mi","memory":"32Mi"},"requests":{"cpu":"10m","ephemeral-storage":"16Mi","memory":"16Mi"}}` | Resource requests/limits for these init containers (`nc` peaks at ~4 MiB). |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
