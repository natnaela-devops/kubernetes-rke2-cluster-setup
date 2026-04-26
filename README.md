# Kubernetes RKE2 Cluster Setup with Rancher & Longhorn

This repository showcases a **production-grade Rancher RKE2 Kubernetes cluster** configuration that I have worked with in real banking and government health system environments.

### What This Demonstrates
- Setting up a secure, scalable RKE2 cluster using Rancher
- Distributed persistent storage with Longhorn
- Proper node role separation (control-plane + workers)
- Basic Helm chart structure for deploying applications

### Tech Stack
- Kubernetes (RKE2)
- Rancher
- Longhorn Storage
- Helm
- Docker

### Files in This Repository
- `cluster.yml` – RKE2 cluster definition
- `longhorn-storage.yaml` – Longhorn deployment
- `storageclass.yaml` – Custom StorageClass for PVs
- `helm/` folder – Example chart structure

### Deployment Example
```bash
# Install Longhorn
kubectl apply -f longhorn-storage.yaml

# Apply StorageClass
kubectl apply -f storageclass.yaml
```

# Real-World Context

I have used similar setups to run critical health information systems and banking workloads with high availability, automated storage provisioning, and easy horizontal scaling.

Feel free to use this as a reference for your own RKE2 deployments.

## Architecture Diagram

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
        E[Longhorn Distributed Storage\n3 Replicas]
    end

    subgraph "Applications"
        F[Microservices / Banking & Health Apps\nDeployed via Helm]
    end

    A --> D
    B --> D
    C --> D
    D --> E
    D --> F

    classDef highlight fill:#e3f2fd,stroke:#1976d2,stroke-width:2px;
    class E highlight

    style A fill:#fff3e0
    style F fill:#e8f5e9
