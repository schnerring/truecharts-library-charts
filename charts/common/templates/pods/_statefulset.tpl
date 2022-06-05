{{/*
This template serves as the blueprint for the StatefulSet objects that are created
within the common library.
*/}}
{{- define "common.statefulset" }}
{{- $values := .Values }}
{{- $releaseName := .Release.Name }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "common.names.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.controller.labels }}
      {{- tpl ( toYaml . ) $ | nindent 4 }}
    {{- end }}
  {{- with .Values.controller.annotations }}
  annotations:
    {{- tpl ( toYaml . ) $ | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ .Values.controller.revisionHistoryLimit }}
  replicas: {{ .Values.controller.replicas }}
  {{- $strategy := default "RollingUpdate" .Values.controller.strategy }}
  {{- if and (ne $strategy "OnDelete") (ne $strategy "RollingUpdate") }}
    {{- fail (printf "Not a valid strategy type for StatefulSet (%s)" $strategy) }}
  {{- end }}
  updateStrategy:
    type: {{ $strategy }}
    {{- if and (eq $strategy "RollingUpdate") .Values.controller.rollingUpdate.partition }}
    rollingUpdate:
      partition: {{ .Values.controller.rollingUpdate.partition }}
    {{- end }}
  selector:
    matchLabels:
      {{- include "common.labels.selectorLabels" . | nindent 6 }}
  serviceName: {{ include "common.names.fullname" . }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- tpl ( toYaml . ) $ | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.labels.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- tpl ( toYaml . ) $ | nindent 8 }}
        {{- end }}
    spec:
      {{- include "common.controller.pod" . | nindent 6 }}
  volumeClaimTemplates:
    {{- range $index, $vct := .Values.volumeClaimTemplates }}
    {{- $vctname := $index }}
    {{- if $vct.name }}
    {{- $vctname := $vct.name }}
    {{- end }}
    - metadata:
        name: {{ tpl $vctname $ }}
      spec:
        accessModes:
          - {{ tpl ( $vct.accessMode | default "ReadWriteOnce" ) $ | quote }}
        resources:
          requests:
            storage: {{ tpl ( $vct.size | default "999Gi" ) $ | quote }}
        {{ include "common.storage.class" ( dict "persistence" $vct "global" $) }}
    {{- end }}
{{- end }}
