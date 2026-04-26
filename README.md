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

### Architecture

```mermaid
flowchart TD
    subgraph "Control Plane Nodes"
        A[Control Plane + etcd\n192.168.10.10]
    end

    subgraph "Worker Nodes"
        B[Worker Node 1\n192.168.10.11]
        C[Worker Node 2\n192.168.10.12]
    end

    subgraph "Rancher + RKE2 Cluster"
        D[Rancher Management\n+ RKE2 Kubernetes]
    end

    subgraph "Storage Layer"
        E[Longhorn Distributed Storage\n3 Replicas - High Availability]
    end

    subgraph "Applications"
        F[Microservices & Critical Apps\nBanking & Health Systems\nDeployed via Helm]
    end

    A --> D
    B --> D
    C --> D
    D --> E
    D --> F

    classDef highlight fill:#e3f2fd,stroke:#1976d2,stroke-width:2px;
    class E highlight
```
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
