# clusters/ — Per-Environment Helm Values

## What is this folder?
Contains the environment-specific values files for each service.
These override the base values in helm-charts/generic-service/values.yaml.

## Structure
```
clusters/
  dev/
    user-service/
      values-dev.yaml      ← Dev config: 1 replica, debug logs, lower resources
    payment-service/
      values-dev.yaml
    order-service/
      values-dev.yaml
  staging/
    user-service/
      values-staging.yaml  ← Staging config: 2 replicas, HPA on, PDB on
    ...
  prod/
    user-service/
      values-prod.yaml     ← Prod config: 3+ replicas, HA, zone anti-affinity
    ...
```

## The MOST IMPORTANT field in these files: image.tag

```yaml
image:
  tag: "abc1234"   # ← THE CI PIPELINE UPDATES THIS LINE
```

When CI builds a new image, it runs:
```bash
sed -i 's|tag: ".*"|tag: "newsha123"|' clusters/dev/user-service/values-dev.yaml
git commit -m "update user-service dev to newsha123"
git push
```
Argo CD sees the diff → re-renders Helm chart → applies new Deployment to cluster.

## Values Merge Priority (lowest to highest)
1. helm-charts/generic-service/values.yaml   (base defaults)
2. clusters/{env}/{service}/values-{env}.yaml (env+service specific)

Only fields listed in the env values file are overridden.
Everything else uses the base defaults.
