{{/*
Expand the name of the chart.
*/}}
{{- define "thehive-flow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
Truncated to 63 chars per DNS label spec.
If release name contains the chart name, it's used as the full name.
*/}}
{{- define "thehive-flow.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Chart name and version label value, used by app.kubernetes.io/version and helm.sh/chart.
*/}}
{{- define "thehive-flow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Recommended Kubernetes labels (https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/).
*/}}
{{- define "thehive-flow.labels" -}}
helm.sh/chart: {{ include "thehive-flow.chart" . }}
{{ include "thehive-flow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: thehive-flow
{{- end -}}

{{/*
Selector labels — the strict subset used for Deployment.spec.selector
and Service.spec.selector. Must be stable across upgrades.
*/}}
{{- define "thehive-flow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "thehive-flow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Name of the ServiceAccount to use.
*/}}
{{- define "thehive-flow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "thehive-flow.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Image reference — falls back to .Chart.AppVersion when .Values.image.tag is empty.
*/}}
{{- define "thehive-flow.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}

{{/*
DNS host of the Postgres database endpoint. The operator supplies Postgres
outside this chart, typically using an operator like CNPG, or a managed Postgres database.
*/}}
{{- define "thehive-flow.postgresql.host" -}}
{{- .Values.postgresql.host -}}
{{- end -}}

{{/*
DNS name of the Temporal frontend.

When the bundled Temporal subchart is enabled (default), return
`<release>-temporal-frontend` — the Service that the temporalio/temporal
subchart creates under the parent release name.

Otherwise, fall back to the operator-supplied `externalTemporal.host`. The client
speaks plaintext, unauthenticated gRPC only — no TLS/mTLS and no API key — so this
must be a Temporal frontend reachable in-cluster or over a private network
(VPC/peering). Temporal Cloud (which requires mTLS or an API key) is NOT supported.
*/}}
{{- define "thehive-flow.temporal.host" -}}
{{- if .Values.temporal.enabled -}}
{{- printf "%s-temporal-frontend" .Release.Name -}}
{{- else -}}
{{- .Values.externalTemporal.host -}}
{{- end -}}
{{- end -}}

{{/*
Port of the Temporal frontend. The bundled subchart exposes the frontend on the
fixed 7233; an external Temporal uses the operator-supplied externalTemporal.port.
*/}}
{{- define "thehive-flow.temporal.port" -}}
{{- if .Values.temporal.enabled -}}
7233
{{- else -}}
{{- .Values.externalTemporal.port -}}
{{- end -}}
{{- end -}}

{{/*
Port extracted from a "host:port" bind address, so containerPorts derive from the
configured bind addresses (e.g. config.api.public.addr "0.0.0.0:8081" -> 8081).
*/}}
{{- define "thehive-flow.addrPort" -}}
{{- splitList ":" . | last -}}
{{- end -}}

{{/*
Parse a Kubernetes memory quantity (1Gi, 1024Mi, 2G, 1073741824) into bytes.

Validates rather than matching best-effort: Kubernetes accepts exponent notation
("1e3"), which a lenient parser reads as 1 byte -- a container that then starts
with its GC collecting continuously. Anything this cannot parse exactly stops the
render instead.
*/}}
{{- define "thehive-flow.memoryBytes" -}}
{{- /*
  A bare byte count is a legal Kubernetes quantity, and YAML reads it as a NUMBER,
  not a string: `toString` then yields "1.073741824e+09" and the parse below fails
  on a perfectly valid value. Only a `--set-string` (or a quoted value) arrives as
  text. So non-strings are formatted as plain integers first.
*/ -}}
{{- $q := "" -}}
{{- if kindIs "string" . -}}
{{- $q = . -}}
{{- else -}}
{{- $q = printf "%.0f" (float64 .) -}}
{{- end -}}
{{- $n := regexFind "^[0-9]+(\\.[0-9]+)?" $q -}}
{{- $u := regexFind "[A-Za-z]*$" $q -}}
{{- if not $n -}}
{{- fail (printf "memory quantity %q has no numeric part" $q) -}}
{{- end -}}
{{- if ne (printf "%s%s" $n $u) $q -}}
{{- fail (printf "cannot parse memory quantity %q" $q) -}}
{{- end -}}
{{- $mult := dict "" 1.0 "k" 1e3 "M" 1e6 "G" 1e9 "T" 1e12 "Ki" 1024.0 "Mi" 1048576.0 "Gi" 1073741824.0 "Ti" 1099511627776.0 -}}
{{- if not (hasKey $mult $u) -}}
{{- fail (printf "unsupported memory unit %q in %q" $u $q) -}}
{{- end -}}
{{- printf "%.0f" (mulf (float64 $n) (index $mult $u)) -}}
{{- end -}}

{{/*
Bytes for a GOMEMLIMIT literal, in the grammar the Go runtime actually accepts:
an integer byte count with an optional B/KiB/MiB/GiB/TiB suffix, CASE-SENSITIVE.
Measured against the real binary, not inferred — "900MB", "900mib" and "870.5MiB"
all abort the process at startup with `fatal error: malformed GOMEMLIMIT`, with
nothing in the manifest to explain the CrashLoopBackOff.
*/}}
{{- define "thehive-flow.goMemLimitBytes" -}}
{{- $v := "" -}}
{{- if kindIs "string" . -}}
{{- $v = . -}}
{{- else -}}
{{- $v = printf "%.0f" (float64 .) -}}
{{- end -}}
{{- if not (regexMatch "^[0-9]+(B|KiB|MiB|GiB|TiB)?$" $v) -}}
{{- fail (printf "goMemLimit %q is not a value the Go runtime accepts: an integer byte count with an optional B/KiB/MiB/GiB/TiB suffix (case-sensitive). The container would abort at startup with 'malformed GOMEMLIMIT'." $v) -}}
{{- end -}}
{{- $n := regexFind "^[0-9]+" $v -}}
{{- $u := regexFind "[A-Za-z]*$" $v -}}
{{- $mult := dict "" 1.0 "B" 1.0 "KiB" 1024.0 "MiB" 1048576.0 "GiB" 1073741824.0 "TiB" 1099511627776.0 -}}
{{- printf "%.0f" (mulf (float64 $n) (index $mult $u)) -}}
{{- end -}}

{{/*
GOMEMLIMIT for the TheHive Flow container, or "" when it must not be set.

Go's GC does not read the cgroup ceiling: left to itself it waits for the heap to
double before collecting, so without GOMEMLIMIT the process walks into a hard
OOMKill instead of letting GC pressure push back first. Here that is not a local
nuisance -- the REST API and the Temporal worker share one process, so the kill
restarts the whole platform.

Two invariants hold WHATEVER produced the value -- derived from the percentage or
pinned by goMemLimit -- and that is deliberate: an escape hatch that also disables
the safety checks turns a typo into the very failure this helper exists to prevent,
and it would make the paragraph above false for the one configuration an operator
had to think about.

  1. strictly below resources.limits.memory;
  2. at least 128 MiB of margin under it. That figure is absolute, not a
     percentage, because what it covers is a FIXED cost: GOMEMLIMIT bounds
     runtime-managed memory only, so the mapped binary (90 MiB in the shipped
     image, which builds with -s -w) and memory the kernel holds on the process's
     behalf sit outside it (go doc runtime/debug.SetMemoryLimit). 15% of 1Gi is
     154 MiB and covers it; 15% of 512Mi is 77 MiB and does not.

Both are skipped only when resources.limits.memory is itself unset -- there is
then no ceiling to be below. goMemLimitPercent: 0 is the documented opt-out.
*/}}
{{- define "thehive-flow.gomemlimit" -}}
{{- /*
  Takes a dict, not the root context, because TWO containers run this binary under
  a memory limit: the Deployment and the pre-upgrade migration Job, each with its
  own `resources` and its own percentage. Passing the root context would have tied
  the rule to the Deployment and left the Job's GC uninformed — which is exactly
  the gap this helper exists to close.
    "resources" — the container's resources block
    "percent"   — the percentage to derive from it
    "override"  — an explicit GOMEMLIMIT, or "" to derive
*/ -}}
{{- $limits := (.resources | default dict).limits | default dict -}}
{{- $limit := $limits.memory | default "" -}}
{{- $rendered := "" -}}
{{- $bytes := 0.0 -}}
{{- /*
  Tested for presence, not truthiness: `goMemLimit: 0` written as a YAML NUMBER is
  falsy, so a truthiness test sent it silently down the derived path — the operator
  asked for one thing and got another, with nothing in the manifest to say so.
  Quoted "0" went the other way and rendered a real zero limit. One key, two
  opposite meanings, decided by punctuation.
*/ -}}
{{- $override := .override -}}
{{- if and (not (kindIs "invalid" $override)) (ne ($override | toString) "") -}}
{{- /*
  Rendered as written (so "700MiB" stays readable in the manifest) but CHECKED in
  bytes, below, like the derived path. A YAML number reaches the template as a
  number, so it is normalised first -- otherwise `goMemLimit: 912680550` in a
  values file would render "9.1268055e+08" and abort the container.
*/ -}}
{{- if kindIs "string" $override -}}
{{- $rendered = $override -}}
{{- else -}}
{{- $rendered = printf "%.0f" (float64 $override) -}}
{{- end -}}
{{- $bytes = float64 (include "thehive-flow.goMemLimitBytes" $override) -}}
{{- /*
  Go accepts 0 and treats it as a real limit, so the pod comes up Ready and then
  collects continuously from the first allocation -- no crash, no log, just a
  process spending half its CPU on GC forever. The chart already refuses
  `resources.limits.memory: Gi` for producing exactly this value; refusing it here
  too, and naming the actual opt-out, keeps one meaning per key.
*/ -}}
{{- if eq $bytes 0.0 -}}
{{- fail "goMemLimit is 0, which the Go runtime honours as a real limit: the container would spend its life collecting garbage. To leave GOMEMLIMIT unset, use goMemLimitPercent: 0." -}}
{{- end -}}
{{- else -}}
{{- /*
  Checked as text before conversion: `float64 "abc"` yields 0 without erroring,
  and 0 is the documented opt-out — so an unparseable value would silently render
  a pod with no GOMEMLIMIT at all, which is exactly the state this chart exists to
  prevent.
*/ -}}
{{- if not (regexMatch "^[0-9]+(\\.[0-9]+)?$" (.percent | toString)) -}}
{{- fail (printf "goMemLimitPercent must be a number, got %q" (.percent | toString)) -}}
{{- end -}}
{{- $pct := .percent | float64 -}}
{{- /*
  Strictly below 100: at 100 the soft limit equals the hard limit, so the GC only
  starts pushing back at the point the kernel would already be killing the pod —
  the helper would render a value that contradicts its own reason for existing.
*/ -}}
{{- if ge $pct 100.0 -}}
{{- fail (printf "goMemLimitPercent must be below 100 (0 opts out), got %v" .percent) -}}
{{- end -}}
{{- if and (gt $pct 0.0) $limit -}}
{{- $bytes = floor (mulf (float64 (include "thehive-flow.memoryBytes" $limit)) (divf $pct 100.0)) -}}
{{- $rendered = printf "%.0f" $bytes -}}
{{- end -}}
{{- end -}}
{{- if and $rendered $limit -}}
{{- $limitBytes := float64 (include "thehive-flow.memoryBytes" $limit) -}}
{{- if ge $bytes $limitBytes -}}
{{- fail (printf "GOMEMLIMIT %s is not below resources.limits.memory %v: the GC would only start pushing back once the kernel is already killing the pod." $rendered $limit) -}}
{{- end -}}
{{- if lt (subf $limitBytes $bytes) 134217728.0 -}}
{{- fail (printf "GOMEMLIMIT %s leaves only %.0f MiB under resources.limits.memory %v; GOMEMLIMIT excludes the mapped binary (90 MiB in the shipped image), so at least 128 MiB must remain. Lower goMemLimitPercent (or goMemLimit), or raise resources.limits.memory." $rendered (divf (subf $limitBytes $bytes) 1048576.0) $limit) -}}
{{- end -}}
{{- end -}}
{{- $rendered -}}
{{- end -}}

{{/*
Name of the existing Secret holding TheHive Flow's Postgres password.
*/}}
{{- define "thehive-flow.databasePassword.secretName" -}}
{{- .Values.secrets.databasePassword.existingSecret -}}
{{- end -}}

{{/*
Key inside the existing Secret holding TheHive Flow's Postgres password.
*/}}
{{- define "thehive-flow.databasePassword.secretKey" -}}
{{- .Values.secrets.databasePassword.key -}}
{{- end -}}

{{/*
Namespace for Codex Jobs. Defaults to "<release-namespace>-jobs" so untrusted
user code runs isolated from TheHive Flow's own namespace.
*/}}
{{- define "thehive-flow.codex.jobNamespace" -}}
{{- default (printf "%s-jobs" .Release.Namespace) .Values.codex.kubernetes.jobNamespace -}}
{{- end -}}

{{/*
Codex assistant image reference — tag falls back to .Chart.AppVersion.
*/}}
{{- define "thehive-flow.codex.assistantImage" -}}
{{- $tag := default .Chart.AppVersion .Values.codex.kubernetes.assistantImage.tag -}}
{{- printf "%s:%s" .Values.codex.kubernetes.assistantImage.repository $tag -}}
{{- end -}}

{{/*
Existing Secret holding the assistant's STATIC object-store credentials
(AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY). An explicit
codex.kubernetes.objectStoreSecret wins; otherwise it defaults to the blobstore
Secret only when static credentials are in use (blobstore.s3.accessKeyId set).
Empty result means "no secret": the assistant then falls back to the AWS SDK
default credential chain (IRSA / Pod Identity via the codex-jobs ServiceAccount),
mirroring TheHive Flow's own blob store.
*/}}
{{- define "thehive-flow.codex.objectStoreSecret" -}}
{{- if .Values.codex.kubernetes.objectStoreSecret -}}
{{- .Values.codex.kubernetes.objectStoreSecret -}}
{{- else if .Values.blobstore.s3.accessKeyId -}}
{{- .Values.secrets.s3SecretAccessKey.existingSecret -}}
{{- end -}}
{{- end -}}

{{/*
thehive-flow.yml body — shared by the runtime ConfigMap (mounted by the
Deployment) and the pre-install migration hook ConfigMap, so both render
identical config. Include with `nindent 4` under a `thehive-flow.yml: |` block.

auto_migrate is coupled to the migration Job: when the Job runs the migrations
(enabled) pods only verify the schema; when it is disabled pods self-migrate.
*/}}
{{- define "thehive-flow.config" -}}
{{- if ne .Values.blobstore.backend "s3" }}{{- fail (printf "blobstore.backend: %q is not selectable at runtime (memory is unit-test-only; empty and unknown values are rejected at startup); set blobstore.backend: s3." .Values.blobstore.backend) }}{{- end }}
{{- if not .Values.secrets.jwtSymmetricKey.existingSecret }}{{- fail "secrets.jwtSymmetricKey.existingSecret is required (holds the JWT signing key)." }}{{- end }}
{{- if and .Values.config.api.public.enable (not .Values.config.api.public.url) }}{{- fail "config.api.public.url is required." }}{{- end }}
{{- if and .Values.config.api.public.enable .Values.config.api.public.url (not (regexMatch `^https?://(\[[0-9A-Fa-f:.]+\]|[^/?#@:\[\]%]+)(:[0-9]+)?(/([^?#%]|%[0-9A-Fa-f]{2})*)?$` .Values.config.api.public.url)) }}{{- fail "config.api.public.url must be an absolute http(s) URL without credentials, a query or a fragment." }}{{- end }}
{{- if not .Values.secrets.databasePassword.existingSecret }}{{- fail "secrets.databasePassword.existingSecret is required (holds the TheHive Flow Postgres password)." }}{{- end }}
{{- if and (not .Values.temporal.enabled) (not .Values.externalTemporal.host) }}{{- fail "temporal.enabled is false but externalTemporal.host is empty; set externalTemporal.host to your external Temporal frontend." }}{{- end }}
{{- /*
  The bundled Temporal subchart shares TheHive Flow's Postgres, but its datastore
  connectAddr is a static subchart value the parent can't derive from postgresql.*. Fail
  fast if they diverge so repointing postgresql.host doesn't leave Temporal dialing an
  absent service (schema job fails, frontend never serves, wait-temporal burns its timeout).
*/ -}}
{{- if .Values.temporal.enabled }}
{{- $pgAddr := printf "%s:%d" .Values.postgresql.host (int .Values.postgresql.port) }}
{{- $dsDefault := .Values.temporal.server.config.persistence.datastores.default.sql.connectAddr }}
{{- $dsVis := .Values.temporal.server.config.persistence.datastores.visibility.sql.connectAddr }}
{{- if or (ne $pgAddr $dsDefault) (ne $pgAddr $dsVis) }}{{- fail (printf "bundled Temporal's Postgres (default=%s, visibility=%s) must match postgresql.host:port (%s): align temporal.server.config.persistence.datastores.{default,visibility}.sql.connectAddr (and the temporal-user Secret) with postgresql.*, or set temporal.enabled: false to use an external Temporal." $dsDefault $dsVis $pgAddr) }}{{- end }}
{{- end }}
{{- /* The mailer's startup checks, refused at render instead of a CrashLoop. */ -}}
{{- $mailer := .Values.config.modules.workers.activities.mailer }}
{{- if $mailer.host }}
{{- if or (lt (int $mailer.port) 1) (gt (int $mailer.port) 65535) }}{{- fail (printf "config.modules.workers.activities.mailer.port must be 1-65535, got %v." $mailer.port) }}{{- end }}
{{- if and $mailer.user (not .Values.secrets.mailerPassword.existingSecret) }}{{- fail "config.modules.workers.activities.mailer.user is set but secrets.mailerPassword.existingSecret is empty: user and password must be set together." }}{{- end }}
{{- if and .Values.secrets.mailerPassword.existingSecret (not $mailer.user) }}{{- fail "secrets.mailerPassword.existingSecret is set but config.modules.workers.activities.mailer.user is empty: user and password must be set together." }}{{- end }}
{{- if and $mailer.user (not $mailer.tls) (not (has $mailer.host (list "localhost" "127.0.0.1" "::1"))) }}{{- fail "config.modules.workers.activities.mailer: credentials are not sent without tls to a non-loopback host; set mailer.tls: true." }}{{- end }}
{{- end }}
secret_path: /secret

temporal:
  addr: {{ printf "%s:%s" (include "thehive-flow.temporal.host" .) (include "thehive-flow.temporal.port" .) | quote }}

database:
  postgres:
    # URL DSN: golang-migrate (the pre-install migration Job) requires a postgres:// URL, so the
    # password must be URL-safe — percent-encode @ / ? # : in an operator-supplied DB password.
    connection_string: {{ printf "postgres://%s:${FLOW_DB_PASSWORD}@%s:%d/%s?sslmode=%s" .Values.postgresql.username .Values.postgresql.host (int .Values.postgresql.port) .Values.postgresql.database .Values.postgresql.sslMode | quote }}
    auto_migrate: {{ not .Values.migrations.enabled }}

blobstore:
  backend: {{ .Values.blobstore.backend | quote }}
  {{- if eq .Values.blobstore.backend "s3" }}
  s3:
    bucket: {{ .Values.blobstore.s3.bucket | quote }}
    region: {{ .Values.blobstore.s3.region | quote }}
    endpoint: {{ .Values.blobstore.s3.endpoint | quote }}
    use_path_style: {{ .Values.blobstore.s3.usePathStyle }}
    {{- if .Values.blobstore.s3.accessKeyId }}
    access_key_id: {{ .Values.blobstore.s3.accessKeyId | quote }}
    # secret_access_key is injected via the BEEFLOW_SECRET_S3_SECRET_ACCESS_KEY env var
    {{- end }}
  {{- end }}

api:
  public:
    enable: {{ .Values.config.api.public.enable }}
    addr: {{ .Values.config.api.public.addr | quote }}
    url: {{ .Values.config.api.public.url | quote }}
    {{- with .Values.config.api.public.trusted_proxies }}
    trusted_proxies:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    jwt:
      secret: jwt-symmetric-key

modules:
  observability:
    listener:
      addr: {{ .Values.config.modules.observability.listener.addr | quote }}
    metrics:
      prometheus:
        enabled: {{ .Values.config.modules.observability.metrics.prometheus.enabled }}
    pprof:
      enabled: {{ .Values.config.modules.observability.pprof.enabled }}

  workers:
    activities:
      http:
        request_logging: {{ .Values.config.modules.workers.activities.http.request_logging }}
      {{- with .Values.config.modules.workers.activities.egress.allowlist }}
      egress:
        allowlist:
          {{- toYaml . | nindent 10 }}
      {{- end }}
      {{- if .Values.secrets.thehiveApiKey.existingSecret }}
      thehive:
        url: {{ .Values.config.modules.workers.activities.thehive.url | quote }}
        api_key: thehive-api-key
      {{- end }}
      {{- with .Values.config.modules.workers.activities.mailer }}
      {{- if .host }}
      mailer:
        host: {{ .host | quote }}
        port: {{ int .port }}
        tls: {{ .tls }}
        {{- with .user }}
        user: {{ . | quote }}
        # password is injected via the BEEFLOW_SECRET_MAILER_PASSWORD env var
        {{- end }}
        {{- with .from }}
        from: {{ . | quote }}
        {{- end }}
      {{- end }}
      {{- end }}

  runs:
    retention: {{ .Values.config.modules.runs.retention | quote }}
    {{- /* Null follows temporal.enabled: sync only when we own the bundled Temporal, never rewrite an
           external namespace's retention by default. An explicit true/false always wins. */}}
    {{- $syncRetention := .Values.config.modules.runs.syncTemporalRetention }}
    {{- if kindIs "invalid" $syncRetention }}{{- $syncRetention = .Values.temporal.enabled }}{{- end }}
    sync_temporal_retention: {{ $syncRetention }}

  codex:
    backend: {{ .Values.codex.backend | quote }}
    {{- with .Values.codex.languageImages }}
    languages:
      {{- range $name, $image := . }}
      {{ $name | quote }}:
        image: {{ $image | quote }}
      {{- end }}
    {{- end }}
    {{- if eq .Values.codex.backend "kubernetes" }}
    kubernetes:
      namespace: {{ include "thehive-flow.codex.jobNamespace" . | quote }}
      service_account: {{ .Values.codex.kubernetes.serviceAccount | quote }}
      assistant_image: {{ include "thehive-flow.codex.assistantImage" . | quote }}
      {{- with (include "thehive-flow.codex.objectStoreSecret" .) }}
      object_store_secret: {{ . | quote }}
      {{- end }}
      {{- with .Values.codex.kubernetes.imagePullSecrets }}
      image_pull_secrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.codex.kubernetes.resources }}
      resources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.codex.kubernetes.nodeSelector }}
      node_selector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.codex.kubernetes.ttlSecondsAfterFinished }}
      ttl_seconds_after_finished: {{ . }}
      {{- end }}
      {{- with .Values.codex.kubernetes.activeDeadlineSeconds }}
      active_deadline_seconds: {{ . }}
      {{- end }}
      {{- with .Values.codex.kubernetes.gracePeriodSeconds }}
      grace_period_seconds: {{ . }}
      {{- end }}
      {{- with .Values.codex.kubernetes.ephemeralStorage }}
      ephemeral_storage: {{ . | quote }}
      {{- end }}
    {{- end }}
{{- end -}}
