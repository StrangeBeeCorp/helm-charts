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
