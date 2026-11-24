{{- define "inventory.image" -}}
{{- $repository := required "Set image.repository" .Values.image.repository -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" $repository .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" $repository (required "Set image.tag or image.digest" .Values.image.tag) -}}
{{- end -}}
{{- end -}}