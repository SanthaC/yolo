# Project: Full-Stack E-Commerce Platform — Kubernetes Orchestration Explanation

This document explains the design reasoning and implementation choices made when moving the YOLO e-commerce platform from a Docker Compose local setup to a Kubernetes-orchestrated deployment (target platform: Google Kubernetes Engine — GKE). It addresses the assessment objectives required for Week 8 IP4: choice of Kubernetes objects, exposure method, persistent storage, git workflow, runtime/debugging evidence and good practices (versioning/tagging).

# Assessment Objectives

## 1. Choice of Kubernetes objects and reasoning
### Overview
### Frontend — Deployment + Service (LoadBalancer)

Why Deployment?
The frontend is stateless and can be scaled horizontally. A Deployment offers declarative updates, self-healing and rolling updates.

Using a Deployment allows easy scaling for traffic spikes and integrates well with HorizontalPodAutoscaler if needed.

Service type: Service of type LoadBalancer (or Ingress + Service)

Exposes the frontend to the internet via a cloud load balancer provided by GKE. This gives a stable external IP and routes traffic to frontend Pods.

Optionally, an Ingress resource with a TLS certificate can be used to provide HTTPS and host-based routing if a domain is available.

Key features used: readiness and liveness probes, resource requests/limits, imagePullPolicy and proper labels for observability.

### Backend — Deployment + Service (ClusterIP)

Why Deployment?
The backend is also stateless and benefits from the same rolling updates, replica management and self-healing provided by Deployment.

Service type: ClusterIP

The backend service does not need a public IP; it is accessible internally by the frontend using Kubernetes DNS.

This protects the API from direct public exposure and centralizes ingress through the frontend or an API gateway.

Key features used: environment configuration through ConfigMap/Secret, liveness/readiness probes and labels for selectors.

### MongoDB — StatefulSet + Headless Service + PersistentVolumeClaims
Why StatefulSet?

Stateful workloads require stable network identities and persistent storage. StatefulSet assigns deterministic pod names (e.g.app-mongo-statefulset-0) and stable storage that follows the Pod across reschedules.

This is ideal for databases where each replica needs a stable identity and persistent volume.

Headless Service:

A Headless Service (Service with clusterIP: None) is used to provide stable DNS records for each Pod managed by the StatefulSet.

Persistent Storage:

The StatefulSet uses volumeClaimTemplates to request PersistentVolumeClaims (PVCs) for each Pod. In GKE this typically binds to a PersistentVolume backed by a gcePersistentDisk via the default storage class.

Replica Strategy:

For a single-node deployment we run 1 replica (mongo-0). For higher availability, a proper MongoDB replica set (3+ members) can be deployed using StatefulSet with an init process or an operator to initialize replica set config.

Why not Deployment for DB?

A Deployment lacks stable identities and stable persistent volume binding per replica. If the database pod were re-created, a Deployment might attach a different volume or fail to preserve pod identity — undesirable for stateful databases.

## 2. Method used to expose pods to internet traffic

### Frontend exposure
Primary method: Service type LoadBalancer on the frontend service.

GKE provisions a cloud load balancer and assigns an external IP. The URL documented in the repository README is of the form http://10.102.182.148/ depending on the Service port mapping.

Alternate/Production-ready method: Use an Ingress resource backed by the GKE ingress controller (HTTP(S) Load Balancer). Benefits:

TLS termination (HTTPS)

Host/path-based routing (serve API and UI under a single domain)

### Backend exposure
The backend is exposed internally via ClusterIP. The frontend communicates with the backend through that internal service name.

If needed for external clients or CI tests, restrict exposure via an Ingress path.

## 3. Persistent storage (design and implementation)

### Requirements
Data added via the application (e.g. products) must remain available after Pod restarts, node reboots or even Pod replacement.

### Implementation choices
GKE-backed PersistentVolumes via the default StorageClass (which uses Google Compute Engine Persistent Disks on GKE).

MongoDB runs in a StatefulSet with volumeClaimTemplates creating PVCs for each replica. Each PVC is bound to a PV with storage provided by GKE.

### Persistence verification procedure
1. Add a product using the UI.

2. Confirm the product exists in the UI.

3. Delete the mongo Pod: kubectl delete pod app-mongo-statefulset-0

4. Wait for the Pod to come back and then refresh the UI. The previously-added product should still be present.

This demonstrates that the PVC/PV pair persist data independently of the Pod lifecycle.

## 4. Successful running and debugging measures applied

### Deployment steps executed 
1.gcloud container clusters create yolo-cluster --num-nodes=3

2.gcloud container clusters get-credentials yolo-cluster

3.kubectl apply -f frontend-deployment.yaml
  kubectl apply -f frontend-deployment.yaml

4.kubectl get pods --watch to monitor rollout

### Commands used to validate and debug
kubectl get pods  — check pod nodes and status

kubectl get pvc / kubectl get pv — confirm PV and PVC binding

kubectl describe pod app-mongo-statefulset-0    — inspect volume mounts and events

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
Follows Semantic Versioning: v1.0.0, v1.0.1, etc. Each deployment manifest references a fixed image tag (not latest) to ensure reproducibility.

Why fixed tags?

Prevents unexpected updates during kubectl rollout restart or recreations. Tags make rollbacks explicit and simple.

### AdditionL best practices applied

Resource requests & limits: small defaults were added to avoid noisy node scheduling and ensure predictable resource consumption.

Health checks: readiness and liveness probes to remove unhealthy pods and avoid sending traffic to non-ready pods.

ConfigMaps & Secrets: environment configuration (like MONGODB_URI) is stored in a ConfigMap and sensitive values in Secrets rather than hard-coding inside images.

Labels & annotations: used to identify app, component, environment which helps with management and monitoring.

ImagePullPolicy: set to IfNotPresent for stable tags and Always for frequently updated tags during CI-only tests.

Logging: Application logs are written to stdout/stderr so they integrate with GKE logging stacks.

## 6. Git Workflow used

In this project, I used a simple Git workflow based mainly on the master branch. All my work; including creating, editing and updating files was done directly on the master branch.

After making changes, I followed these main steps:

Add changes: git add . — to stage all modified files.

Commit changes: git commit -m "Description of the update" — to save the changes with a message.

Push changes: git push origin master — to upload the latest version of the project to GitHub.

I didn’t create separate branches. This made the process straightforward and easy to manage.