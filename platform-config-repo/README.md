# platform-config-repo — GitOps Source of Truth

This is the ONLY repo that Argo CD watches.
No application source code lives here — only deployment configuration.

## The Golden Rule
> "A commit to this repo = a change to what runs in Kubernetes"
> "A commit to user-service-repo = a change to application code only (CI handles rest)"

---

## How It All Connects (read this first)

```
Developer pushes code to user-service-repo
   ↓
GitLab CI builds Docker image → pushes to ECR (image tag = abc1234)
   ↓
CI updates THIS repo: clusters/dev/user-service/values-dev.yaml
  changes:  tag: "old123"  →  tag: "abc1234"
   ↓
Argo CD detects the Git diff in this repo
   ↓
Argo CD renders Helm chart (helm-charts/generic-service/) 
  with merged values (values.yaml + values-dev.yaml)
   ↓
Argo CD applies the rendered manifests to the EKS cluster
   ↓
New pod with image:abc1234 rolls out in dev-user-service namespace
```

---

## Folder-by-Folder Guide

### bootstrap/   ← START HERE (applied once per cluster, manually)
```
bootstrap/dev/root-app.yaml       ← kubectl apply THIS to the dev cluster ONCE
bootstrap/staging/root-app.yaml   ← kubectl apply THIS to staging cluster ONCE  
bootstrap/prod/root-app.yaml      ← kubectl apply THIS to prod cluster ONCE
```
**Purpose:** Root Application for the App-of-Apps pattern.
After you apply this ONCE, Argo CD takes over and manages everything else.
This file tells Argo CD: "watch the apps/dev/ folder for child app definitions".

---

### apps/   ← Argo CD reads this. You write these once per service.
```
apps/dev/
  user-service.yaml       ← Argo CD Application: deploy user-service to DEV
  payment-service.yaml    ← Argo CD Application: deploy payment-service to DEV
  order-service.yaml      ← Argo CD Application: deploy order-service to DEV

apps/staging/             ← same files, pointing to staging values
apps/prod/                ← same files, NO auto-sync (manual approval required)
```
**Purpose:** Defines HOW each service is deployed (which chart, which values, which namespace).
**Who changes this:** Platform team, rarely (only if Argo CD config changes).
**Does NOT contain:** Image tags, replica counts, resource limits.

---

### clusters/   ← CI PIPELINE UPDATES THIS on every build
```
clusters/dev/user-service/values-dev.yaml        ← CI updates image.tag here
clusters/dev/payment-service/values-dev.yaml     ← CI updates image.tag here
clusters/dev/order-service/values-dev.yaml       ← CI updates image.tag here

clusters/staging/user-service/values-staging.yaml
clusters/prod/user-service/values-prod.yaml      ← Higher replicas, HA config
```
**Purpose:** Per-environment, per-service Helm values overrides.
**Who changes this:** 
  - The `image.tag` field: CI pipeline (automated)
  - Everything else: Platform team (manual, via PR)
**This is where image tags live** — when CI pushes abc1234, it edits values-dev.yaml.

---

### helm-charts/generic-service/   ← ONE chart for ALL microservices
```
helm-charts/generic-service/
  Chart.yaml               ← Chart metadata (name, version)
  values.yaml              ← BASE DEFAULTS (lowest priority in merge)
  templates/
    deployment.yaml        ← Kubernetes Deployment template
    service.yaml           ← Kubernetes Service template  
    hpa.yaml               ← HorizontalPodAutoscaler (if autoscaling.enabled=true)
    serviceaccount.yaml    ← ServiceAccount with IRSA annotation
    pdb.yaml               ← PodDisruptionBudget (if enabled=true)
    _helpers.tpl           ← Reusable Go template helper functions
```
**Purpose:** The actual Kubernetes YAML templates. Parameterised by values.yaml.
**Who changes this:** Platform team, rarely (when adding new K8s features).
**Key concept:** This one chart is reused for user-service, payment-service, order-service,
and any future service. Only the values files differ.

---

### platform/   ← Cluster-wide infrastructure config
```
platform/networking/namespace-strategy.yaml   ← Kubernetes Namespace definitions
platform/security/argocd-projects.yaml        ← Argo CD RBAC (who can deploy where)
platform/security/external-secrets.yaml       ← AWS Secrets Manager → K8s Secrets
platform/monitoring/prometheus-servicemonitor.yaml ← Prometheus auto-discovery
```
**Purpose:** Non-application cluster resources. Applied once, rarely changed.

---

## Values Merge Example (user-service in prod)

Argo CD runs: `helm template` with these value files in order:

```yaml
# 1. helm-charts/generic-service/values.yaml  (base defaults)
replicaCount: 1
image:
  tag: "latest"
autoscaling:
  enabled: false
resources:
  requests:
    cpu: "100m"

# 2. clusters/prod/user-service/values-prod.yaml  (overrides)
replicaCount: 3          # ← overrides base
image:
  tag: "abc1234"         # ← overrides base (set by CI)
autoscaling:
  enabled: true          # ← overrides base
  maxReplicas: 20
resources:
  requests:
    cpu: "200m"          # ← overrides base

# RESULT merged values used to render templates:
replicaCount: 3
image.tag: "abc1234"
autoscaling.enabled: true
autoscaling.maxReplicas: 20
resources.requests.cpu: "200m"
```

---

## Adding a New Service (e.g. notification-service)

1. Create `clusters/dev/notification-service/values-dev.yaml` (set serviceName, image.repository)
2. Create `clusters/staging/notification-service/values-staging.yaml`
3. Create `clusters/prod/notification-service/values-prod.yaml`
4. Create `apps/dev/notification-service.yaml` (Argo CD Application pointing to generic chart)
5. Create `apps/staging/notification-service.yaml`
6. Create `apps/prod/notification-service.yaml`
7. Commit and push → Argo CD App-of-Apps detects new app YAML → auto-deploys

**No Helm chart changes. No CI pipeline changes. Just config files.**
