{{/* Expand the name of the chart */}}
{{- define "thehive.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
If release name contains chart name it will be used as a full name
*/}}
{{- define "thehive.fullname" -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.nameOverride }}
  {{- if contains $name .Release.Name }}
    {{- .Release.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}
{{- end }}

{{/* Create chart name and version as used by the chart label */}}
{{- define "thehive.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "thehive.commonLabels" -}}
app.kubernetes.io/part-of: "TheHive"
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end }}

{{/* TheHive selector labels */}}
{{- define "thehive.selectorLabels" -}}
app.kubernetes.io/name: {{ include "thehive.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* TheHive selector labels formatted for TheHive Pekko config */}}
{{- define "thehive.selectorLabelsForPekko" -}}
  {{- printf "app.kubernetes.io/name=%s,app.kubernetes.io/instance=%s" (include "thehive.name" .) .Release.Name | quote }}
{{- end }}

{{/* TheHive labels */}}
{{- define "thehive.labels" -}}
{{ include "thehive.commonLabels" . }}
{{ include "thehive.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.thehive.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/component: "frontend"
{{- end }}

{{/* TheHive service account name */}}
{{- define "thehive.serviceAccountName" -}}
{{- default (include "thehive.fullname" .) .Values.thehive.serviceAccount.name }}
{{- end }}
