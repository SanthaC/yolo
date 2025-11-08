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

## 5. Good practises and image tagging standards

 (i) Intial BUild/runtime issues - confirmed node:18-slim usage, ensuring basic package compatibility  resulting to the images being built successfully.

 (ii) Client Crash - (ERR_OSSL_EVP_UNSUPPORTED) - Added NODE_OPTIONS: --openssl-legacy-provider to the client service environment in docker-compose.yaml resulting to the client container being started successfully.

 (iii) Persistence Failure (Validation) - Used docker logs brian-yolo-backend to diagnose Mongoose Cast to Number failed error and corrected the client-side input during the test phase resulting to the backend being successfully processing the saved operation.

 (iv) Persistence Failure (Volume) -Used docker compose down -v to delete the old volume before restarting ensuring persistence was successful across shutdowns.

  - The final  application is successfully running, with all three microservices orchestrated via Docker Compose and maintaining persistent data.

## 7. Good Practises and Versioning

(i) Versioning: Uses version: "3.8" for compatibility with modern Docker features and stable networking.

(ii) Service Separation: Frontend, backend, and database are defined as distinct services for modularity and easier management.

(iii) Clear Naming & Tagging: Uses descriptive service names and version-tagged images (e.g v1.0.0) for clarity and version control.

(iv) Custom Network: Implements a user-defined bridge network (app-net) for secure and isolated container communication.

(v)Data Persistence: Uses a named volume (app-mongo-data) to retain MongoDB data across container restarts.

(vi) Dependency Control: Applies depends_on to manage the correct startup order of services.

Restart Policy: Uses restart: always to ensure the backend restarts automatically on failure.

(vi) Environment Variables: Keeps configuration flexible and separate from code for easier management.

(vii) Documentation: Includes clear comments that explain the purpose and function of each service, improving readability and maintenance.
