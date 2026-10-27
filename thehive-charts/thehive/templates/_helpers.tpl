{{/* Expand the name of the chart */}}
{{- define "thehive.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
*/}}
{{- define "thehive.fullname" -}}
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

{{/* Create chart name and version as used by the chart label */}}
{{- define "thehive.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* TheHive metaLabels */}}
{{- define "thehive.metaLabels" -}}
app.kubernetes.io/version: {{ .Values.thehive.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: {{ include "thehive.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "thehive.chart" . }}
{{- with .Values.thehive.labels }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/* TheHive selector labels */}}
{{- define "thehive.matchLabels" -}}
app.kubernetes.io/name: {{ include "thehive.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: "server"
{{- end -}}

{{/* TheHive selector labels formatted for Pekko config */}}
{{- define "thehive.selectorLabelsForPekko" -}}
  {{- printf "app.kubernetes.io/name=%s,app.kubernetes.io/instance=%s" (include "thehive.name" .) .Release.Name | quote }}
{{- end }}

{{/* TheHive resources labels */}}
{{- define "thehive.labels" -}}
{{ include "thehive.metaLabels" . }}
{{ include "thehive.matchLabels" . }}
{{- end -}}

{{/* TheHive ServiceAccount name */}}
{{- define "thehive.serviceAccountName" -}}
{{- default (include "thehive.fullname" .) .Values.thehive.serviceAccount.name }}
{{- end -}}

{{/* TheHive init-container command to check ElasticSearch availability */}}
{{- define "thehive.initContainerCheckEsCurlOptions" -}}
{{- if or (.Values.thehive.index.password) (.Values.thehive.index.k8sSecretName) -}}
  -fkLsS -u "{{ .Values.thehive.index.username | default "elastic" }}:${TH_ELASTICSEARCH_PASSWORD}" --out-null --no-keepalive
{{- else -}}
  -fkLsS --out-null --no-keepalive
{{- end -}}
{{- end -}}

{{/* TheHive init-container command to check ElasticSearch availability */}}
{{- define "thehive.initContainerCheckEsCommand" -}}
{{- if and (.Values.elasticsearch.enabled) (eq (len .Values.thehive.index.hostnames) 0) -}}
  until curl {{ include "thehive.initContainerCheckEsCurlOptions" . }} {{ if .Values.thehive.initContainers.checkElasticsearch.useHttps }}https{{ else }}http{{ end }}://{{ printf "%s-elasticsearch" .Release.Name | trunc 63 }}:9200/_cluster/health; do echo 'Waiting for ElasticSearch'; sleep 5; done
{{- else -}}
  until curl {{ include "thehive.initContainerCheckEsCurlOptions" . }} {{ if .Values.thehive.initContainers.checkElasticsearch.useHttps }}https{{ else }}http{{ end }}://{{ index .Values.thehive.index.hostnames 0 }}:9200/_cluster/health; do echo 'Waiting for ElasticSearch'; sleep 5; done
{{- end -}}
{{- end -}}

{{/* Whether the chart-generated secret is rendered: at least one credential is not a BYO secret */}}
{{- define "thehive.secrets.enabled" -}}
{{- if or (not .Values.thehive.database.k8sSecretName) (not .Values.thehive.index.k8sSecretName) (not .Values.thehive.storage.k8sSecretName) (not .Values.thehive.k8sSecretName) (and (.Values.thehive.cortex.enabled) (not .Values.thehive.cortex.k8sSecretName)) (and (.Values.thehive.flow.enabled) (not .Values.thehive.flow.k8sSecretName) (not (include "thehive.flow.bundled" .))) -}}
true
{{- end -}}
{{- end -}}

{{/* Whether the TheHive Flow subchart is deployed with TheHive */}}
{{- define "thehive.flow.bundled" -}}
{{- if (index .Values "thehive-flow" "enabled") -}}
true
{{- end -}}
{{- end -}}

{{/* Whether the TheHive Flow integration is enabled, with an external or the bundled TheHive Flow */}}
{{- define "thehive.flow.enabled" -}}
{{- if or (.Values.thehive.flow.enabled) (include "thehive.flow.bundled" .) -}}
true
{{- end -}}
{{- end -}}

{{/* Full name of the bundled TheHive Flow, as the subchart helper computes it */}}
{{- define "thehive.flow.fullname" -}}
{{- $flowContext := dict "Values" (index .Values "thehive-flow") "Release" .Release "Chart" (dict "Name" "thehive-flow") -}}
{{- include "thehive-flow.fullname" $flowContext -}}
{{- end -}}

{{/* TheHive Flow URL: the explicit value, else the Service of the bundled TheHive Flow */}}
{{- define "thehive.flow.url" -}}
{{- if .Values.thehive.flow.url -}}
  {{- .Values.thehive.flow.url -}}
{{- else if include "thehive.flow.bundled" . -}}
  {{- printf "http://%s-api:%v" (include "thehive.flow.fullname" .) (index .Values "thehive-flow").service.api.port -}}
{{- end -}}
{{- end -}}

{{/* Secret and key holding the JWT signing key shared with the bundled TheHive Flow */}}
{{- define "thehive.flow.jwtSecretName" -}}
{{- index .Values "thehive-flow" "secrets" "jwtSymmetricKey" "existingSecret" -}}
{{- end -}}

{{- define "thehive.flow.jwtSecretKey" -}}
{{- index .Values "thehive-flow" "secrets" "jwtSymmetricKey" "key" -}}
{{- end -}}

{{/* Fail on TheHive Flow settings that cannot work */}}
{{- define "thehive.flow.validate" -}}
{{- if include "thehive.flow.enabled" . -}}
  {{- if and (.Values.thehive.flow.signingKey) (lt (len .Values.thehive.flow.signingKey) 32) -}}
    {{- fail "thehive.flow.signingKey must be at least 32 characters long: TheHive Flow refuses shorter keys" -}}
  {{- end -}}
  {{- if and (not (include "thehive.flow.bundled" .)) (not .Values.thehive.flow.url) -}}
    {{- fail "thehive.flow.url is required when thehive.flow.enabled=true without the bundled TheHive Flow (thehive-flow.enabled)" -}}
  {{- end -}}
{{- end -}}
{{- if include "thehive.flow.bundled" . -}}
  {{- if not (semverCompare ">=1.29.0-0" .Capabilities.KubeVersion.Version) -}}
    {{- fail (printf "the bundled TheHive Flow (thehive-flow.enabled) requires Kubernetes >= 1.29.0, found %s" .Capabilities.KubeVersion.Version) -}}
  {{- end -}}
  {{- if eq (include "thehive.flow.fullname" .) (include "thehive.fullname" .) -}}
    {{- fail (printf "TheHive and TheHive Flow resources would both be named %q: use a release name that does not contain \"thehive-flow\", or set thehive-flow.fullnameOverride" (include "thehive.fullname" .)) -}}
  {{- end -}}
  {{- if not (include "thehive.flow.jwtSecretName" .) -}}
    {{- fail "thehive-flow.secrets.jwtSymmetricKey.existingSecret is required: it holds the JWT signing key shared by TheHive and TheHive Flow" -}}
  {{- end -}}
  {{- if and (.Values.thehive.flow.k8sSecretName) (ne .Values.thehive.flow.k8sSecretName (include "thehive.flow.jwtSecretName" .)) -}}
    {{- fail "thehive.flow.k8sSecretName must equal thehive-flow.secrets.jwtSymmetricKey.existingSecret: TheHive and TheHive Flow share the JWT signing key" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* TheHive application.conf content: thehive.configFile, plus the Flow connector module when the integration is enabled, thehive.flow.addModule is true and no uncommented line of configFile loads it */}}
{{- define "thehive.configFile" -}}
{{- $configFile := .Values.thehive.configFile -}}
{{- if and (include "thehive.flow.enabled" .) .Values.thehive.flow.addModule (not (regexMatch "(?m)^[ \\t]*scalligraph\\.modules[^#\\n]*connector\\.flow\\.FlowModule" $configFile)) -}}
  {{- $separator := ternary "" "\n" (or (empty $configFile) (hasSuffix "\n" $configFile)) -}}
  {{- $configFile = printf "%s%s# TheHive Flow connector, added by the chart\nscalligraph.modules += \"org.thp.thehive.connector.flow.FlowModule\"\n" $configFile $separator -}}
{{- end -}}
{{- $configFile -}}
{{- end -}}
