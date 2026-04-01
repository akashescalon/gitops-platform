# helm-charts/ — Reusable Helm Chart

## What is this folder?
Contains ONE Helm chart (generic-service) used by ALL microservices.

## Why one chart for all services?
- user-service, payment-service, order-service all deploy the same K8s resources
  (Deployment, Service, HPA, ServiceAccount, PDB)
- The only differences are VALUES (image, replicas, resources, env vars)
- ONE chart = one place to update when K8s best practices change
- Adding service #50 = add values files only, zero chart code changes

## File purposes
```
generic-service/
  Chart.yaml          ← Helm chart metadata (name="generic-service", version="1.0.0")
  values.yaml         ← BASE DEFAULTS for all services/environments
                        (CI never touches this file)
  templates/
    deployment.yaml   ← Renders a K8s Deployment using values
    service.yaml      ← Renders a K8s Service (ClusterIP)
    hpa.yaml          ← Renders HPA only if autoscaling.enabled=true
    serviceaccount.yaml ← Renders SA with IRSA annotation
    pdb.yaml          ← Renders PDB only if podDisruptionBudget.enabled=true
    _helpers.tpl      ← Go template helper functions (name, labels, etc)
```

## How Helm renders a manifest
Argo CD runs approximately:
```bash
helm template user-service ./helm-charts/generic-service \
  --namespace dev-user-service \
  -f helm-charts/generic-service/values.yaml \
  -f clusters/dev/user-service/values-dev.yaml
```
Output = the actual K8s YAML applied to the cluster.
