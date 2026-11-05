{{- define "realworld.image" -}}
{{- $root := index . 0 -}}
{{- $component := index . 1 -}}
{{- $tag := (index $root.Values $component).image.tag -}}
{{ required "registry is required" $root.Values.registry }}/realworld-{{ required "environment is required" $root.Values.environment }}-{{ $component }}:{{ required (printf "%s.image.tag is required" $component) $tag }}
{{- end -}}

{{- define "realworld.labels" -}}
app.kubernetes.io/name: {{ . }}
app.kubernetes.io/part-of: realworld
{{- end -}}

{{/* Environment shared by the backend Deployment and the migration Job. */}}
{{- define "realworld.backendEnv" -}}
- name: APP_ENV
  value: prod
- name: POSTGRES_HOST
  value: {{ required "postgres.host is required" .Values.postgres.host | quote }}
- name: POSTGRES_PORT
  value: {{ .Values.postgres.port | quote }}
- name: POSTGRES_DB
  value: {{ required "postgres.db is required" .Values.postgres.db | quote }}
{{- end -}}

{{/* The backend image declares a named user, so a numeric UID is required for runAsNonRoot. */}}
{{- define "realworld.podSecurityContext" -}}
runAsNonRoot: true
runAsUser: 10001
runAsGroup: 10001
seccompProfile:
  type: RuntimeDefault
{{- end -}}

{{- define "realworld.containerSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop: [ALL]
{{- end -}}
