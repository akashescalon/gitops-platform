# apps/ — Argo CD Application Definitions

## What is this folder?
Each YAML file here is an Argo CD "Application" object.
It tells Argo CD: "watch this Helm chart + these values → deploy to this namespace"

## Who uses these files?
Argo CD reads them. Platform team writes them (once per service, rarely changes).

## Structure
```
apps/
  dev/
    user-service.yaml      ← Application: user-service → dev-user-service namespace
    payment-service.yaml   ← Application: payment-service → dev-payment-service namespace
    order-service.yaml     ← Application: order-service → dev-order-service namespace
  staging/
    user-service.yaml      ← Same structure, staging namespace, staging values
    payment-service.yaml
    order-service.yaml
  prod/
    user-service.yaml      ← Same structure, prod namespace, NO auto-sync
    payment-service.yaml
    order-service.yaml
```

## What does one Application YAML do?
```yaml
source:
  path: helm-charts/generic-service   # Use this Helm chart
  helm:
    valueFiles:
      - values.yaml                    # Load base defaults first
      - ../../clusters/dev/user-service/values-dev.yaml  # Then apply dev overrides
destination:
  namespace: dev-user-service          # Deploy here
```

## What does NOT go here?
- Image tags (those go in clusters/{env}/{service}/values-{env}.yaml)
- Resource limits (those go in values files)
- Application source code (that's in user-service-repo)
