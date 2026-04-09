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

{{/* Cortex init-container command to check ElasticSearch availability */}}
{{- define "cortex.initContainerCheckEsCurlOptions" -}}
{{- if or (.Values.cortex.index.password) (.Values.cortex.index.k8sSecretName) -}}
  -kLsS -u "{{ .Values.cortex.index.username | default "elastic" }}:${CORTEX_ELASTICSEARCH_PASSWORD}" --output /dev/null -w '%{http_code}' --no-keepalive
{{- else -}}
  -kLsS --output /dev/null -w '%{http_code}' --no-keepalive
{{- end -}}
{{- end -}}

{{/* Cortex init-container command to check ElasticSearch availability */}}
{{- define "cortex.initContainerCheckEsCommand" -}}
{{- if .Values.cortex.index.uri -}}
  {{- $url := (trimSuffix "/" .Values.cortex.index.uri) -}}
  while true; do STATUS=$(curl {{ include "cortex.initContainerCheckEsCurlOptions" . }} {{ $url }}/_cluster/health 2>/dev/null); if [ "$STATUS" = "200" ]; then echo 'ElasticSearch is ready'; break; elif [ "$STATUS" = "000" ]; then echo "Waiting for ElasticSearch at {{ $url }} (connection refused)"; elif [ "$STATUS" = "401" ]; then echo "ERROR: Authentication failed (HTTP 401). Check cortex.index.username and cortex.index.password"; elif [ "$STATUS" = "403" ]; then echo "ERROR: Access denied (HTTP 403). Check user permissions"; else echo "Waiting for ElasticSearch at {{ $url }} (HTTP $STATUS)"; fi; sleep 5; done
{{- else -}}
  {{- $scheme := ternary "https" "http" .Values.cortex.initContainers.checkElasticsearch.useHttps -}}
  {{- $host := "" -}}
  {{- if and .Values.elasticsearch.enabled (eq (len .Values.cortex.index.hostnames) 0) -}}
    {{- $host = printf "%s-elasticsearch" .Release.Name | trunc 63 -}}
  {{- else -}}
    {{- $host = index .Values.cortex.index.hostnames 0 -}}
  {{- end -}}
  while true; do STATUS=$(curl {{ include "cortex.initContainerCheckEsCurlOptions" . }} {{ $scheme }}://{{ $host }}:9200/_cluster/health 2>/dev/null); if [ "$STATUS" = "200" ]; then echo 'ElasticSearch is ready'; break; elif [ "$STATUS" = "000" ]; then echo "Waiting for ElasticSearch at {{ $scheme }}://{{ $host }}:9200 (connection refused)"; elif [ "$STATUS" = "401" ]; then echo "ERROR: Authentication failed (HTTP 401). Check cortex.index.username and cortex.index.password"; elif [ "$STATUS" = "403" ]; then echo "ERROR: Access denied (HTTP 403). Check user permissions"; else echo "Waiting for ElasticSearch at {{ $scheme }}://{{ $host }}:9200 (HTTP $STATUS)"; fi; sleep 5; done
{{- end -}}
{{- end -}}

{{/* Validate Cortex HTTP secret */}}
{{- define "cortex.validateHttpSecret" -}}
{{- if not .Values.cortex.k8sSecretName -}}
  {{- $defaultSecret := "ChangeThisSecretWithOneContainingAtLeast32Chars" -}}
  {{- if eq .Values.cortex.httpSecret $defaultSecret -}}
    {{- fail "ERROR: You must change the default httpSecret value. Please set cortex.httpSecret to a secure random string of at least 32 characters, or provide an existing secret via cortex.k8sSecretName." -}}
  {{- end -}}
  {{- if lt (len .Values.cortex.httpSecret) 32 -}}
    {{- fail (printf "ERROR: cortex.httpSecret must be at least 32 characters long (current length: %d). Please provide a longer secret or use cortex.k8sSecretName to reference an existing secret." (len .Values.cortex.httpSecret)) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* Validate ElasticSearch password synchronization */}}
{{- define "cortex.validateElasticsearchPassword" -}}
{{- if and .Values.elasticsearch.enabled .Values.elasticsearch.security.enabled -}}
  {{- if and (not .Values.cortex.index.k8sSecretName) (not .Values.elasticsearch.security.existingSecret) -}}
    {{- $cortexPassword := .Values.cortex.index.password -}}
    {{- $esPassword := .Values.elasticsearch.security.elasticPassword -}}
    {{- if and $cortexPassword $esPassword -}}
      {{- if ne $cortexPassword $esPassword -}}
        {{- fail (printf "ERROR: Password mismatch detected!\n  cortex.index.password and elasticsearch.security.elasticPassword must match when using the embedded ElasticSearch with security enabled.\n  Current values:\n    - cortex.index.password: %s\n    - elasticsearch.security.elasticPassword: %s\n  Please set both to the same value or use cortex.index.k8sSecretName / elasticsearch.security.existingSecret to reference existing secrets." $cortexPassword $esPassword) -}}
      {{- end -}}
    {{- else if $esPassword -}}
      {{- if not $cortexPassword -}}
        {{- fail "ERROR: elasticsearch.security.elasticPassword is set but cortex.index.password is empty.\n  When using ElasticSearch with security enabled, you must also set cortex.index.password to the same value.\n  Alternatively, use cortex.index.k8sSecretName to reference an existing secret." -}}
      {{- end -}}
    {{- else if $cortexPassword -}}
      {{- if not $esPassword -}}
        {{- fail "ERROR: cortex.index.password is set but elasticsearch.security.elasticPassword is empty.\n  When using ElasticSearch with security enabled, you must also set elasticsearch.security.elasticPassword to the same value.\n  Alternatively, use elasticsearch.security.existingSecret to reference an existing secret." -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}
