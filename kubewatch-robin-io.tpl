---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
  namespace: "{{ KUBEWATCH_NAMESPACE|default('default', true) }}"
data:
  .kubewatch.yaml: |
    handler:
      webhook:
        url: {{ KUBEWATCH_WEBHOOK_URL }}
    resource:
      deployment: false
      replicationcontroller: false
      replicaset: false
      daemonset: false
      services: false
      pod: false
      secret: false
      configmap: false
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
rules:
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "watch", "list"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
  namespace: "{{ KUBEWATCH_NAMESPACE|default('default', true) }}"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
subjects:
  - kind: ServiceAccount
    name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
    namespace: "{{ KUBEWATCH_NAMESPACE|default('default', true) }}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}-deployment"
  namespace: "{{ KUBEWATCH_NAMESPACE|default('default', true) }}"
spec:
  selector:
    matchLabels:
      app: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
  replicas: 1
  template:
    metadata:
      labels:
        app: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
    spec:
      serviceAccountName: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
      containers:
      - image: "{{ KUBEWATCH_IMAGE }}"
        name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: config-volume
          mountPath: /root
      volumes:
      - name: config-volume
        configMap:
          name: "{{ KUBEWATCH_RESOURCE_NAME|default('kubewatch', true) }}"
