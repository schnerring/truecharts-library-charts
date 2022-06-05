{{/* vim: set filetype=mustache: */}}
{{/*
Return  the proper Storage Class
{{ include "common.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $ ) }}
*/}}
{{- define "common.storage.class" -}}

{{- $storageClass :=  .persistence.storageClass  -}}
{{- $output := "" -}}

{{- if ( hasKey .persistence "storageClass" ) -}}
  {{- if $storageClass -}}
    {{- if (eq "-" $storageClass) -}}
      {{- $output = "\"\"" -}}
    {{- else if (eq "SCALE-ZFS" $storageClass ) }}
      {{- $output = ( printf "ix-storage-class-%s"  .global.Release.Name ) -}}
    {{- else }}
      {{- $output = $storageClass -}}
    {{- end -}}
    {{- printf "storageClassName: %s" $output -}}
  {{- else -}}
    {{- printf "%s" "storageClassName: " -}}
  {{- end -}}
{{- else if .global }}
  {{- if .global.Values.storageClass -}}
    {{- $output = .global.Values.storageClass -}}
  {{- else if .global.Values.ixChartContext }}
    {{- $output = ( printf "ix-storage-class-%s"  .global.Release.Name ) -}}
  {{- else if .global.Values.global  -}}
    {{- if .global.Values.global.storageClass -}}
      {{- $output = .global.Values.global.storageClass -}}
    {{- end -}}
    {{- if or ( .global.Values.global.ixChartContext ) ( .global.Values.global.isSCALE ) -}}
      {{- $output = ( printf "ix-storage-class-%s"  .global.Release.Name ) -}}
    {{- end }}
  {{- end -}}
  {{- if $output -}}
    {{- printf "storageClassName: %s" $output -}}
  {{- end -}}
{{- end -}}
{{- end -}}
