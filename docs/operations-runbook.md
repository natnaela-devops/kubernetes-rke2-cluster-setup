# RKE2 Operations Runbook

This runbook defines the minimum operational checks for the reference architecture. Replace all example values and agree the final recovery objectives with the service owner before production use.

## Deployment gates

- Three server nodes can reach each other on the required RKE2 and etcd ports.
- The fixed endpoint forwards TCP `9345` and `6443` to healthy server nodes.
- Forward and reverse DNS, NTP, and certificate SAN values are correct.
- The CIS host preparation and `scripts/preflight.sh` complete without failures.
- `/etc/rancher/rke2/token`, registry credentials, and private CAs are root-owned with mode `0600`.
- Longhorn has at least three eligible worker nodes on independent failure domains.
- Etcd and Longhorn backups are stored outside the cluster and a restore has been tested.

## Bootstrap order

1. Configure the load balancer using `examples/haproxy.cfg` as a reference.
2. Start server 1 with `config/server-bootstrap.yaml`.
3. Confirm the local API and etcd member are healthy.
4. Start server 2 and server 3 with `config/server-join.yaml`, one at a time.
5. Confirm all three servers are `Ready` and etcd has three healthy members.
6. Start the agent nodes with `config/agent.yaml`.
7. Confirm workloads schedule only to worker nodes.
8. Install Longhorn and verify all manager, CSI, and instance-manager components.

## Health checks

Run from a server node:

```bash
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
/var/lib/rancher/rke2/bin/kubectl get nodes -o wide
/var/lib/rancher/rke2/bin/kubectl get --raw='/readyz?verbose'
/var/lib/rancher/rke2/bin/kubectl -n kube-system get pods
/var/lib/rancher/rke2/bin/kubectl -n longhorn-system get pods
```

Confirm the latest etcd snapshot:

```bash
rke2 etcd-snapshot ls
```

## Reliability signals

Alert on these conditions before user-facing availability is affected:

- Fewer than three healthy server nodes or loss of etcd quorum margin
- Kubernetes API error rate, latency, or readiness failures
- Node `NotReady`, filesystem pressure, memory pressure, or certificate expiry risk
- Failed or stale etcd snapshots
- Longhorn volumes degraded, faulted, rebuilding for too long, or missing backups
- Pods unavailable beyond their rollout or disruption budget

Recommended service-level indicators include successful Kubernetes API requests, workload availability, successful scheduled snapshots, and healthy storage replicas. Define SLO targets from business requirements rather than copying generic percentages.

## Single-server failure exercise

1. Confirm all three servers and the fixed endpoint are healthy.
2. Stop RKE2 on one non-bootstrap server during an approved test window.
3. Verify the API remains available through the fixed endpoint and etcd retains quorum.
4. Confirm monitoring detects the failed member and records the start time.
5. Restore the server, confirm it rejoins, and document time to detection and recovery.

Do not test a second simultaneous server failure: a three-member etcd cluster tolerates only one failed member.

## Etcd recovery safeguards

- Copy snapshots to storage outside the cluster.
- Verify file integrity, encryption, retention, and restore permissions.
- Test restoration in an isolated environment on a defined schedule.
- Record the tested recovery-point objective and recovery-time objective.
- Follow the RKE2 restore procedure for the exact installed version; do not improvise commands during an incident.

## Upgrade procedure

1. Review the RKE2 support matrix, Kubernetes version-skew policy, release notes, and known issues.
2. Validate backups and restore readiness.
3. Upgrade one server at a time while maintaining etcd quorum.
4. Upgrade remaining servers, then agents in controlled batches.
5. Validate API health, DNS, networking, storage, ingress, and representative workloads after every batch.
6. Stop and execute the rollback plan if error rate, latency, or availability breaches the agreed threshold.

## Incident record

Capture timestamps, impact, detection source, responders, mitigations, recovery validation, contributing factors, and follow-up actions. Convert recurring manual remediation into automation only after the failure mode is understood.
