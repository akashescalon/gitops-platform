# platform/ — Cluster-Wide Infrastructure Config

## What is this folder?
Non-application resources that are set up once and rarely change.
These are things like namespaces, RBAC rules, and secret syncing config.

## Files
```
platform/
  networking/
    namespace-strategy.yaml    ← Creates all K8s Namespaces (dev-user-service, prod-payment-service, etc.)

  security/
    argocd-projects.yaml       ← Argo CD AppProjects = RBAC (who can deploy to which namespace)
                                  dev-project:  only dev-* namespaces
                                  prod-project: only prod-* namespaces, only platform team
    external-secrets.yaml      ← ExternalSecret CRDs: pull secrets from AWS Secrets Manager
                                  into K8s Secrets at runtime

  monitoring/
    prometheus-servicemonitor.yaml ← Tells Prometheus to scrape /metrics from all services
```

## When do you change these files?
- namespace-strategy.yaml: When adding a new service (add its namespace here)
- argocd-projects.yaml: When adding a new team or changing who can deploy where
- external-secrets.yaml: When adding a new secret (e.g. new 3rd party API key)
- servicemonitor.yaml: When adding a new namespace to monitor
