{{/* Volumes included by the controller */}}
{{- define "common.controller.volumeMounts" -}}
  {{- range $index, $item := .Values.persistence }}
  {{- if not $item.noMount }}
    {{- $mountPath := (printf "/%v" $index) -}}
    {{- if eq "hostPath" (default "pvc" $item.type) -}}
      {{- $mountPath = $item.hostPath -}}
    {{- end -}}
    {{- with $item.mountPath -}}
      {{- $mountPath = . -}}
    {{- end }}
    {{- if and $item.enabled (ne $mountPath "-") }}
- mountPath: {{ tpl $mountPath $ }}
  name: {{ tpl $index $ }}
      {{- with $item.subPath }}
  subPath: {{ tpl . $ }}
      {{- end }}
      {{- with $item.readOnly }}
  readOnly: {{ tpl . $ }}
      {{- end }}
      {{- with $item.mountPropagation }}
  mountPropagation: {{ tpl . $ }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}

  {{- if eq .Values.controller.type "statefulset" }}
    {{- range $index, $vct := .Values.volumeClaimTemplates }}
    {{- $vctname := $index }}
    {{- if $vct.name }}
    {{- $vctname := $vct.name }}
    {{- end }}
    {{- if not $vct.noMount }}
- mountPath: {{ tpl $vct.mountPath $ }}
  name: {{ tpl $vctname $ }}
      {{- if $vct.subPath }}
  subPath: {{ tpl $vct.subPath $ }}
      {{- end }}
    {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
