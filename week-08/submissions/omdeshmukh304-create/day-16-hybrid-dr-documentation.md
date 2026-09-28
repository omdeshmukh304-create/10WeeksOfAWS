# Day 16 — Cross-Region EC2 Backup and Disaster Recovery

## Overview

Day 16 demonstrates a backup-and-restore disaster recovery workflow for an EC2 workload. The source workload runs in **Mumbai (`ap-south-1`)** with an encrypted EBS root volume. AWS Backup creates a recovery point in the primary Region, copies that recovery point to **N. Virginia (`us-east-1`)**, restores it as a new EC2 instance, and validates the recovered application.

### Recovery Design

| Item | Value |
|---|---|
| Primary Region | `ap-south-1` — Mumbai |
| DR Region | `us-east-1` — N. Virginia |
| DR Strategy | Backup and Restore |
| RTO Objective | 30 minutes |
| RPO Objective | 60 minutes |
| Source Backup Vault | `om-day16-primary-vault` |
| DR Backup Vault | `om-day16-dr-vault` |
| Source Workload | EC2 |
| Backup Storage | Encrypted EBS |
| Validation | HTTP 200, `/health`, application marker, IMDSv2 |

> **Security note:** Account IDs, ARNs, resource IDs, IP addresses, hosted-zone IDs, certificate validation tokens, signed URLs, private keys, private DNS information, console URLs, and billing information are masked in evidence screenshots.

---
architectur
![alt text](<ChatGPT Image Sep 28, 2026, 10_55_34 PM-1.png>)
---

## 1. Source EC2 and Encrypted EBS

The Mumbai EC2 instance was used as the primary workload. Its root EBS volume was configured as an encrypted 8 GiB gp3 volume. The source workload was validated before backup.

**Evidence:** Source EC2 state and encrypted EBS configuration.

![alt text](<ChatGPT Image Sep 27, 2026, 11_52_00 PM-1.png>)



### Evidence recorded

- Source Region: `ap-south-1`
- EC2 instance: Running
- Root volume: 8 GiB gp3
- EBS encryption: Enabled
- IMDSv2: Required
- Source application and synthetic `DAY16` marker validated separately

---

## 2. AWS Backup IAM Role

AWS Backup uses an approved service role instead of administrator access. The role was checked for the required AWS Backup permissions.

**Approved policies:**

- `AWSBackupServiceRolePolicyForBackup`
- `AWSBackupServiceRolePolicyForRestores`

![alt text](<ChatGPT Image Sep 27, 2026, 11_54_51 PM-1.png>)

### IAM validation

The backup role was not granted `AdministratorAccess`. The role provides the AWS Backup permissions required for backup and restore operations.

---

## 3. Target Region Dependencies

The DR environment was prepared in **N. Virginia (`us-east-1`)**. The target VPC, public subnet, security group, KMS encryption key, and EC2 capacity/quota were checked before restore.


### Dependency check

- Target Region: `us-east-1`
- Target VPC/subnet available
- Public subnet available for restored EC2
- DR security group configured
- Destination KMS key available
- EC2 quota/capacity checked
- Required application dependency: Nginx/web service

---

## 4. Source Backup and Recovery Point

An on-demand AWS Backup job was created for the Mumbai EC2 instance. The job completed successfully and produced an EC2 recovery point in the primary backup vault.

![alt text](<ChatGPT Image Sep 28, 2026, 12_37_34 AM-1.png>)

### Backup result

- Backup job: **Completed**
- Source vault: `om-day16-primary-vault`
- Resource type: EC2
- Recovery point: Created successfully
- Backup size: 8 GiB
- Encryption: Enabled

---

## 5. Cross-Region Copy

The completed Mumbai recovery point was copied to the DR Region.

**Source:** `ap-south-1`  
**Destination:** `us-east-1`

![alt text](<ChatGPT Image Sep 28, 2026, 12_31_58 AM-1.png>)

### Copy result

- Copy job: **Completed**
- Source Region: `ap-south-1`
- Destination Region: `us-east-1`
- Resource type: EC2
- Destination vault: `om-day16-dr-vault`

The recovery point becomes useful for the DR RPO only after the cross-Region copy has completed.

---

## 6. Destination Vault and Encrypted Recovery Point

The copied recovery point was verified inside the N. Virginia backup vault.

![alt text](<ChatGPT Image Sep 28, 2026, 12_37_34 AM-1-1.png>)

### Destination evidence

- Region: `us-east-1`
- Vault: `om-day16-dr-vault`
- Recovery point: Present
- Status: Completed
- Resource type: EC2
- Destination encryption: Enabled

This confirms that a usable encrypted recovery point was available in the DR Region before restoration.

---

## 7. Restore Job

The copied recovery point was restored using AWS Backup. The restore operation created a **new EC2 instance** rather than reusing the original Mumbai instance.

![alt text](<ChatGPT Image Sep 28, 2026, 12_40_56 AM-1.png>)
### Restore result

- Restore job: **Completed**
- Restore type: EC2
- Restore duration shown by AWS Backup: approximately 1 minute
- Destination Region: `us-east-1`
- Restored resource: New EC2 instance

---

## 8. Restored EC2 in N. Virginia

The restored EC2 instance was verified in N. Virginia.

![alt text](<ChatGPT Image Sep 28, 2026, 12_37_34 AM-2.png>)

### Restored instance validation

- Region: `us-east-1`
- Availability Zone: `us-east-1a`
- Instance state: **Running**
- Instance type: `t3.micro`
- Status checks: **3/3 checks passed**
- Restored instance ID is distinct from the original Mumbai instance ID

---

## 9. Restored Application Validation

After restoration, the application/web service was validated from the restored EC2 instance.

![alt text](<ChatGPT Image Sep 28, 2026, 12_49_04 AM-1.png>)
### Application validation

The restored workload confirmed:

- Nginx service: **active (running)**
- Local HTTP response: **HTTP 200 OK**
- `/health`: **healthy**
- Region: **N. Virginia (`us-east-1`)**
- New restored instance ID displayed
- Synthetic marker: **DAY16**
- Environment marker: **Restored from AWS Backup**

This demonstrates application-level recovery rather than relying only on the AWS Backup restore-job status.

---

## 10. IMDSv2 Validation

IMDSv2 was used on the restored EC2 instance to independently confirm the Region and instance identity.

![alt text](<ChatGPT Image Sep 28, 2026, 12_51_55 AM-1.png>)
### IMDSv2 result

```text
Region:
us-east-1

Instance ID:
<restored-instance-id>
```

The metadata values matched the restored EC2 instance shown in the AWS Console.

---

# RTO and RPO

## RTO

The workload RTO objective was set to **30 minutes**.

Achieved RTO should be calculated from the recorded incident detection time through recovery declaration, restore, application configuration, validation, and any required cutover.

```text
Achieved RTO =
Detection
+ Recovery declaration
+ Restore
+ Configuration
+ Application validation
+ DNS/cutover (if used)
```

### Recorded milestones

| Milestone | UTC Time |
|---|---|
| Failure detection / incident record | `2026-09-27 17:00:47 UTC` |
| Recovery declaration | `2026-09-27 17:02:32 UTC` |
| Restore job | Completed |
| Application validation | Record exact validation timestamp from evidence |

> Replace the final validation time with the exact timestamp from the terminal evidence before publishing the final achieved RTO.

## RPO

The workload RPO objective was set to **60 minutes**.

RPO is based on the latest **usable copied recovery point**, not merely the time when the source backup started.

```text
Achieved RPO =
Incident time
− Latest usable copied recovery-point completion time
```

Record the exact completion time of the latest copied recovery point and calculate the final RPO before submission.

---

# DR and Hybrid Connectivity Decisions

## VPN vs Direct Connect

For this disposable backup-and-restore workload, a permanent hybrid connectivity service was not required.

- **Site-to-Site VPN:** suitable when encrypted connectivity over the public internet is required with relatively quick deployment.
- **Direct Connect:** suitable when dedicated/private network connectivity, predictable network performance, and long-term hybrid integration are required.
- Neither service was created solely for this lab.

## Transit Gateway

Transit Gateway was treated as an architectural option for larger environments where multiple VPCs, accounts, or networks need centralized connectivity.

It was not created solely for this disposable Day 16 workload.

## Route 53 Resolver / Hybrid DNS

Route 53 Resolver endpoints are useful when DNS queries must flow between AWS VPCs and on-premises networks.

They were considered as an architectural dependency, but were not deployed solely for evidence in this lab.

## Private Endpoints

VPC interface endpoints / PrivateLink can keep service traffic private and reduce dependency on public internet paths.

For this workload, the restore path did not require creating additional billable interface endpoints solely for evidence.

### Optional resources

Private hosted zones, S3 gateway endpoints, and Route 53 DR failover can be implemented as optional extensions. They should be clearly marked as optional if they are not deployed.

---

# Why a Completed Backup Does Not Prove RTO

A completed backup proves that a recovery point was created successfully. It does **not** prove that the complete application can be recovered within the required RTO.

The RTO includes the time required to detect the incident, declare recovery, locate a usable recovery point, copy or access the recovery point, restore the infrastructure, configure dependencies, start the application, validate health, and perform DNS or traffic cutover if required.

Therefore, Day 16 measures recovery at the application level using HTTP, `/health`, the synthetic marker, Region information, and IMDSv2 identity.

---

# Troubleshooting

### AWS Backup service-role permissions

The AWS Backup default service role was verified with the required backup and restore policies:

```text
AWSBackupServiceRolePolicyForBackup
AWSBackupServiceRolePolicyForRestores
```

Administrator access was not used as the permanent solution.

### Ubuntu source/restore environment

The workload used an Ubuntu/Nginx environment. The application document root and service validation were adapted to the restored Ubuntu environment.

### Recovery validation

The restored workload was not considered recovered merely because the AWS Backup restore job completed. Nginx, HTTP 200, `/health`, the Day 16 marker, and IMDSv2 were validated after restoration.

---

# Evidence Checklist

- [x] Encrypted Mumbai EC2 source
- [x] `/health`, metadata, and synthetic marker
- [x] AWS Backup role with approved backup and restore policies
- [x] No AdministratorAccess used for the backup role
- [x] RTO/RPO and backup/restore strategy documented
- [x] Target Region network, KMS, SG, and quota/dependency checks
- [x] Completed source backup job and recovery point
- [x] Completed cross-Region copy job
- [x] Destination vault contains encrypted recovery point
- [x] Completed restore job
- [x] Distinct restored EC2 instance
- [x] Restored page shows DR success, `us-east-1`, new ID, and DAY16
- [x] Restored `/health` returns `healthy`
- [x] IMDSv2 confirms Region and instance ID
- [ ] Final achieved RTO calculation — insert exact final validation timestamp
- [ ] Final achieved RPO calculation — insert exact copied recovery-point completion timestamp
- [x] VPN / Direct Connect / Transit Gateway / Resolver decisions documented
- [x] Optional private DNS/endpoint/failover items clearly identified
- [ ] Cleanup proof in both Regions
- [ ] Day 16 public-post link

---

# Cleanup

After successful validation, remove disposable Day 16 resources according to the lab cleanup procedure.

Record evidence for:

- Mumbai EC2
- Restored N. Virginia EC2
- EBS volumes/snapshots where applicable
- Source and destination AWS Backup recovery points
- Source and destination backup vaults
- KMS key
- Security groups
- Temporary network resources
- Any optional resources that were deployed

> Do not delete recovery evidence before the documentation and required public submission evidence have been captured.

---

# Architecture Explanation

Day 16 implements a backup-and-restore disaster recovery architecture between Mumbai (`ap-south-1`) and N. Virginia (`us-east-1`). The primary workload is an EC2 instance using an encrypted EBS root volume. AWS Backup protects the source workload and creates a recovery point in the Mumbai backup vault. The completed recovery point is then copied across Regions into a dedicated N. Virginia backup vault using destination-region encryption.

The architecture separates the production workload from its DR recovery data. This means that a failure affecting the source workload does not require the original EC2 instance to remain available for recovery. Instead, the copied recovery point becomes the recovery source. AWS Backup restores that recovery point as a new EC2 instance in the DR Region. The restored instance uses the target Region's network, subnet, security group, and KMS dependencies.

Application validation is an important part of the recovery process. A completed restore job alone does not prove that the workload is operational. The restored instance was therefore checked at multiple levels: the Nginx service was running, localhost returned HTTP 200, `/health` returned `healthy`, and the application page displayed the DR Region, new instance ID, and `DAY16` marker. IMDSv2 was also queried to independently confirm that the restored instance reported `us-east-1` and its own instance ID.

The design uses a backup-and-restore DR strategy because the lab workload is disposable and does not require a continuously running secondary environment. The trade-off is that recovery requires time to restore infrastructure and validate the application. RTO and RPO therefore must be measured from actual recovery milestones rather than inferred from backup completion alone.

Hybrid connectivity services such as Site-to-Site VPN, Direct Connect, Transit Gateway, and Route 53 Resolver were treated as architectural decisions rather than billable resources created only for evidence. They become more relevant when a production workload requires private connectivity, centralized network routing, hybrid DNS, or continuous cross-environment dependencies.

---

# Public Submission

- Day 16 public post: `<ADD PUBLIC POST LINK>`
- Week 8 repository: `<ADD GITHUB REPOSITORY LINK>`
- Main architecture image: `day16-hybrid-dr.png`

## Evidence Directory

```text
evidence/
└── day16-hybrid-and-dr/
    ├── 01-source-ec2-storage.png
    ├── 02-backup-iam-role.png
    ├── 03-target-region-dependencies.png
    ├── 04-source-backup-recovery-point.png
    ├── 05-cross-region-copy.png
    ├── 06-destination-vault-recovery-point.png
    ├── 07-restore-job.png
    ├── 08-restored-ec2.png
    ├── 09-restored-application-validation.png
    └── 10-imdsv2-validation.png
```
