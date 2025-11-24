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
  -fkLsS -u '{{ .Values.thehive.index.username | default "elastic" }}:${CORTEX_ELASTICSEARCH_PASSWORD}' --out-null --no-keepalive
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
