# Kubernetes RKE2 Cluster Setup with Rancher & Longhorn

Production-grade Rancher RKE2 Kubernetes cluster configuration with distributed storage, similar to setups I have deployed for banking systems and government health facilities in Ethiopia.

### What This Demonstrates
- Secure multi-node RKE2 cluster using Rancher
- High-availability persistent storage with Longhorn (3 replicas)
- Node role separation (control-plane + workers)
- Dynamic volume provisioning with custom StorageClass
- Basic Helm deployment structure for applications

### Tech Stack
- Kubernetes (RKE2)
- Rancher
- Longhorn Storage
- Helm
- Docker

### Files Included
- `cluster.yml` — RKE2 cluster definition with node roles and networking
- `longhorn-storage.yaml` — Longhorn deployment via HelmChart
- `storageclass.yaml` — Default StorageClass for persistent volumes
- `helm-example/values.yaml` — Sample values for application deployment

## Architecture Overview

```mermaid
flowchart TD
    subgraph "Control Plane"
        CP[Control Plane + etcd<br>192.168.10.10]
    end

    subgraph "Worker Nodes"
        W1[Worker Node 1<br>192.168.10.11]
        W2[Worker Node 2<br>192.168.10.12]
    end

    RKE2[Rancher + RKE2 Kubernetes Cluster]

    subgraph "Storage"
        LH[Longhorn Distributed Storage<br>3 Replicas - High Availability]
    end

    Apps[Applications / Microservices<br>Banking & Health Systems<br>via Helm]

    CP --> RKE2
    W1 --> RKE2
    W2 --> RKE2
    RKE2 --> LH
    RKE2 --> Apps
## Quick Deployment Steps

### 1. Deploy Longhorn
```bash
kubectl apply -f longhorn-storage.yaml
```
### 2. Apply StorageClass
```bash
kubectl apply -f storageclass.yaml
```
### 3. Deploy sample app with Helm (example)
```bash
helm install my-app ./helm-example
```

## Real-World Usage
I have applied similar configurations to run critical health information systems and banking workloads, achieving reliable persistent storage, easy scaling, and reduced manual operations.
Feel free to fork or use as a reference for your own RKE2 deployments.
