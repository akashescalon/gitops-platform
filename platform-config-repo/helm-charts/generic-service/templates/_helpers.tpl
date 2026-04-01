{{/*
=============================================================================
templates/_helpers.tpl  — Reusable template helpers
=============================================================================
*/}}

{{/* Expand the name of the chart */}}
{{- define "generic-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name */}}
{{- define "generic-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Values.serviceName | default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Chart label */}}
{{- define "generic-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels applied to all resources */}}
{{- define "generic-service.labels" -}}
helm.sh/chart: {{ include "generic-service.chart" . }}
{{ include "generic-service.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: platform
environment: {{ .Values.environment }}
{{- end }}

{{/* Selector labels */}}
{{- define "generic-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Values.serviceName }}
{{- end }}

{{/* Service account name */}}
{{- define "generic-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
