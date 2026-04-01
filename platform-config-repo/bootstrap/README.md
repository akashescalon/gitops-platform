# bootstrap/ — Cluster Bootstrap (applied ONCE manually)

## What is this folder?
Contains the ROOT Argo CD Application for each cluster.
You apply this ONCE after installing Argo CD. It bootstraps everything else.

## How to use
```bash
# For dev cluster:
kubectl apply -f bootstrap/dev/root-app.yaml

# For staging cluster:
kubectl apply -f bootstrap/staging/root-app.yaml

# For prod cluster:
kubectl apply -f bootstrap/prod/root-app.yaml
```

## What happens after you apply root-app.yaml?

root-app.yaml says: "watch the apps/dev/ folder"
Argo CD finds:    apps/dev/user-service.yaml
                  apps/dev/payment-service.yaml
                  apps/dev/order-service.yaml
Argo CD creates:  Application "user-service-dev"
                  Application "payment-service-dev"
                  Application "order-service-dev"
Each of those then deploys their Helm chart to the cluster.

## You NEVER need to edit bootstrap/ files unless:
- You change the Git repo URL
- You change the branch Argo CD watches
- You want to change sync policies globally
