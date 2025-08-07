{{/* Expand the name of the chart */}}
{{- define "cortex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
*/}}
{{- define "cortex.fullname" -}}
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
{{- define "cortex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Cortex metaLabels */}}
{{- define "cortex.metaLabels" -}}
app.kubernetes.io/version: {{ .Values.cortex.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: {{ include "cortex.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "cortex.chart" . }}
{{- with .Values.cortex.labels }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/* Cortex selector labels */}}
{{- define "cortex.matchLabels" -}}
app.kubernetes.io/name: {{ include "cortex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: "server"
{{- end -}}

{{/* Cortex resources labels */}}
{{- define "cortex.labels" -}}
{{ include "cortex.metaLabels" . }}
{{ include "cortex.matchLabels" . }}
{{- end -}}

{{/* Cortex ServiceAccount name */}}
{{- define "cortex.serviceAccountName" -}}
{{- default (include "cortex.fullname" .) .Values.cortex.serviceAccount.name }}
{{- end -}}

{{/* Cortex PersistentVolumeClaim name */}}
{{- define "cortex.persistentVolumeClaimName" -}}
{{- if .Values.cortex.persistentVolumeClaim.name -}}
  {{- .Values.cortex.persistentVolumeClaim.name | quote -}}
{{- else -}}
  {{- printf "%s-shared-fs-claim" (include "cortex.fullname" .) -}}
{{- end -}}
{{- end -}}
