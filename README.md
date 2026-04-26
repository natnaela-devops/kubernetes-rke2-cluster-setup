# Kubernetes RKE2 Cluster Setup with Rancher & Longhorn

This repository demonstrates a **production-ready Rancher RKE2 Kubernetes cluster** configuration, similar to the high-availability setups I have deployed and maintained for banking systems and government health facilities in Ethiopia.

### Key Features
- Rancher RKE2 cluster configuration
- Longhorn for distributed block storage
- Proper node roles (control-plane, etcd, worker)
- Basic Helm chart structure for application deployment
- Secure and scalable architecture best practices

### Tech Stack Used
- Kubernetes (RKE2)
- Rancher
- Docker
- Longhorn Storage
- Helm

### Files Included
- `cluster.yml` — Main RKE2 cluster configuration
- `longhorn-storage.yaml` — Longhorn deployment manifest
- `storageclass.yaml` — Custom StorageClass for persistent volumes
- `helm/` folder — Example Helm chart structure

### How to Deploy (Example Steps)
1. Install RKE2 on nodes following official Rancher documentation
2. Apply Longhorn:
   ```bash
   kubectl apply -f longhorn-storage.yaml