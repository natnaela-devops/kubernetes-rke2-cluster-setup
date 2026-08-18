{{- define "platform-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "platform-demo.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "platform-demo.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "platform-demo.labels" -}}
app.kubernetes.io/name: {{ include "platform-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}

{{- define "platform-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
