# Day 8 – AWS Storage & Placement

Hands-on documentation for **Week 4 – Day 8 of #10WeeksOfAWS**.

## Covered

- Amazon EBS gp3
- XFS filesystem
- UUID-based mounting and `/etc/fstab`
- EBS resize: 2 GiB → 4 GiB
- XFS filesystem growth
- EBS snapshots and point-in-time recovery
- Encrypted cross-Region snapshot copy
- Amazon Data Lifecycle Manager (DLM)
- Amazon EFS and NFS TCP 2049
- Shared EFS access from two EC2 instances
- Persistent EFS mounting
- EC2 Placement Groups: Cluster, Spread, Partition

> **Publishing note:** Mask AWS account IDs, ARNs, IP addresses, instance/volume/snapshot IDs, tokens, credentials and other sensitive values before publishing screenshots.

## 1. EBS Persistence

**Requirement → Choice → Reason:** Persistent block storage → **EBS gp3** → durable block storage for EC2.

The volume was formatted as XFS, identified by UUID, mounted at `/data`, and configured for persistence through `/etc/fstab`.

```bash
lsblk
sudo blkid /dev/<device>
sudo mkdir -p /data
sudo mount UUID=<filesystem-uuid> /data
findmnt /data
df -h /data
```

Example `/etc/fstab` entry:

```text
UUID=<filesystem-uuid> /data xfs defaults,nofail 0 2
```

## 2. EBS Resize + XFS Growth

The EBS volume was expanded from **2 GiB → 4 GiB**. XFS was then expanded without recreating the filesystem:

```bash
sudo xfs_growfs /data
df -h /data
```

## 3. Snapshot & Point-in-Time Recovery

A file was created before the snapshot and later recovered from the restored volume. The test demonstrated that data created after the snapshot is not present in the restored point-in-time copy.

```text
Before snapshot
      |
      +-- before-snapshot.txt
      |
    SNAPSHOT
      |
      +-- after-snapshot.txt
      |
    RESTORE
      |
      +-- before-snapshot.txt  ✓
      +-- after-snapshot.txt   ✗
```

### Safety lesson

**Always verify the block device before running `mkfs`.**

**Never run `mkfs` on a restored volume when the goal is data recovery.** A restored EBS volume already contains the filesystem and data captured by the snapshot.

## 4. Cross-Region Disaster Recovery

An encrypted snapshot copy was created from **Mumbai (`ap-south-1`)** to **Sydney (`ap-southeast-2`)**, demonstrating a cross-Region disaster-recovery pattern.

## 5. Data Lifecycle Manager

DLM was configured for the training EBS volume using a resource tag such as:

```text
Name = Week4-Ubuntu-Training
```

The policy provides scheduled snapshot management and retention.

## 6. Amazon EFS

An encrypted EFS filesystem was created with mount targets in the Mumbai Region. NFS access was configured on **TCP 2049**.

The filesystem was mounted using NFS 4.1:

```bash
sudo mkdir -p /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1 <efs-dns-name>:/ /mnt/efs
findmnt /mnt/efs
```

## 7. Shared EFS Validation

Two EC2 instances used the same EFS filesystem. EC2-1 created a file and EC2-2 successfully read it; EC2-2 then created another file and EC2-1 successfully read it. This validates shared storage across both clients.

## 8. Persistent EFS Mount

EFS was configured in `/etc/fstab`:

```text
<efs-dns-name>:/ /mnt/efs nfs4 defaults,_netdev,nofail 0 0
```

After reboot, `findmnt /mnt/efs` confirmed the EFS mount was restored automatically.

## 9. EC2 Placement Groups

| Group | Strategy | Purpose |
|---|---|---|
| `Week4-Cluster` | Cluster | Low latency / high network performance |
| `Week4-Spread` | Spread | Failure isolation |
| `Week4-Partition` | Partition | Distributed workload isolation |

The Partition group used **2 partitions**.

# Evidence Screenshots

## 1. EBS XFS / UUID setup
![alt text](<WhatsApp Image 2026-08-13 at 10.43.49 PM.jpeg>)
## 2. EBS resize and XFS growth
![alt text](<WhatsApp Image 2026-08-13 at 10.11.24 PM.jpeg>)

## 3. Data before snapshot
![alt text](<WhatsApp Image 2026-08-13 at 10.12.46 PM.jpeg>)

## 4. Source volume after snapshot
![alt text](<WhatsApp Image 2026-08-13 at 10.13.03 PM.jpeg>)
## 5. Reboot persistence
![alt text](<WhatsApp Image 2026-08-13 at 10.14.01 PM.jpeg>)
## 6. Placement Groups
![alt text](<WhatsApp Image 2026-08-13 at 10.15.06 PM.jpeg>)
## 7. EFS mount and shared file
![alt text](<WhatsApp Image 2026-08-13 at 10.15.06 PM-1.jpeg>)
## 8. EFS filesystem
![alt text](<WhatsApp Image 2026-08-13 at 10.15.16 PM.jpeg>)


---

## Key Takeaways

- EBS provides persistent block storage for EC2.
- UUID + `/etc/fstab` provides stable persistent mounting.
- EBS resize and filesystem growth are separate operations.
- EBS snapshots provide point-in-time recovery.
- Cross-Region snapshot copies support disaster recovery.
- DLM automates snapshot lifecycle management using tags.
- EFS provides shared file storage for multiple EC2 clients.
- EFS uses NFS TCP 2049 for network access.
- Cluster, Spread and Partition solve different placement requirements.

## Cleanup

Lab resources were cleaned up after validation to avoid unnecessary AWS charges.

## AWS Services

Amazon EC2 · Amazon EBS · EBS Snapshots · Amazon Data Lifecycle Manager · Amazon EFS · Amazon VPC/Security Groups · EC2 Placement Groups

---

**10 Weeks of AWS – Week 4, Day 8**

#AWS #AmazonEBS #AmazonEFS #EC2 #CloudArchitecture #AWSLearning #DevOps #10WeeksOfAWS
