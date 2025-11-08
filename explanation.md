# Project: Full-Stack E-Commerce Platform — Kubernetes Orchestration Explanation

This document explains the design reasoning and implementation choices made when moving the YOLO e-commerce platform from a Docker Compose local setup to a Kubernetes-orchestrated deployment (target platform: Google Kubernetes Engine — GKE). It addresses the assessment objectives required for Week 8 IP4: choice of Kubernetes objects, exposure method, persistent storage, git workflow, runtime/debugging evidence and good practices (versioning/tagging).

# Assessment Objectives

## 1. Choice of Kubernetes objects and reasoning



## 2. Method used to expose pods to internet traffic



## 3. Persistent storage (design and implementation)



## 4. Successful running and debugging measures applied
### Deployment steps executed 
1.gcloud container clusters create yolo-cluster --num-nodes=3

2.gcloud container clusters get-credentials yolo-cluster

3.kubectl apply -f frontend-deployment.yaml
  kubectl apply -f frontend-deployment.yaml

4.kubectl get pods --watch to monitor rollout

### Commands used to validate and debug
kubectl get pods -o wide — check pod nodes and status

kubectl get pvc / kubectl get pv — confirm PV and PVC binding

kubectl describe pod mongo-0 — inspect volume mounts and events

kubectl logs <pod> — check application logs for errors

kubectl exec -it <pod> -- /bin/sh — run internal diagnostics (curl backend, check files)

### Real issues encountered and fixes
1. Client build runtime error (ERR_OSSL_EVP_UNSUPPORTED)

Cause: Node.js + OpenSSL v3 compatibility for some libraries used in the React toolchain.

Fix: Added NODE_OPTIONS=--openssl-legacy-provider in the client image runtime environment (or build-time ENV) to restore compatibility.

2. Mongoose CastError when saving non-numeric price

Cause: Client-side validation missing; backend expected a Number type for price.

Fix: Enforced client-side numeric validation and added backend validation/error handling with descriptive messages.

3. Volume/persistence validation

Procedure: removed and re-created PVC/PV as part of testing to ensure new volumes were properly bound — used kubectl delete pvc only when reinitializing state intentionally.

## 5. Good Practises and image tagging standards

### Image tagging and versioning
Follows Semantic Versioning: v1.0.0, v1.1.0, etc. Each deployment manifest references a fixed image tag (not latest) to ensure reproducibility.

Why fixed tags?

Prevents unexpected updates during kubectl rollout restart or recreations. Tags make rollbacks explicit and simple.

### AdditionL best practices applied

Resource requests & limits: small defaults were added to avoid noisy node scheduling and ensure predictable resource consumption.

Health checks: readiness and liveness probes to remove unhealthy pods and avoid sending traffic to non-ready pods.

ConfigMaps & Secrets: environment configuration (like MONGODB_URI) is stored in a ConfigMap and sensitive values in Secrets rather than hard-coding inside images.

Labels & annotations: used to identify app, component, environment which helps with management and monitoring.

ImagePullPolicy: set to IfNotPresent for stable tags and Always for frequently updated tags during CI-only tests.

Logging: Application logs are written to stdout/stderr so they integrate with GKE logging stacks.