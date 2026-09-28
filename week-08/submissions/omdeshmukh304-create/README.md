# Week 8 — Edge Security, DNS & Disaster Recovery

Week 8 covers two practical AWS labs:

- **Day 15:** Route 53, CloudFront, ACM, S3 Origin Access Control, Signed URLs, WAF, health checks, weighted routing, and failover.
- **Day 16:** Cross-Region EC2 backup and disaster recovery using AWS Backup, encrypted EBS, KMS, cross-Region recovery-point copy, and EC2 restore.



---

## Day 15 — Route 53, CloudFront, ACM & Edge Security

### Objective

Build an edge-delivery architecture where:

- S3 remains private.
- CloudFront accesses S3 through Origin Access Control (OAC).
- ACM provides HTTPS for the custom CloudFront hostname.
- Route 53 manages DNS and routing policies.
- CloudFront caching and invalidation are verified.
- A private path is protected using a CloudFront signed URL.
- Health checks and routing policies are tested.
- WAF protection is validated safely.

The lab uses Mumbai (`ap-south-1`) for the primary workload and N. Virginia (`us-east-1`) for the secondary endpoint. The CloudFront viewer certificate is requested from ACM in `us-east-1`.

### Day 15 Flow

```text
User
  |
  v
Route 53 DNS
  |
  v
CloudFront
  |
  +---- ACM Certificate / HTTPS
  |
  +---- WAF
  |
  v
Private S3 Bucket
  |
  v
Origin Access Control (OAC)
```

For routing-policy testing:

```text
Route 53
  |
  +---- Primary Endpoint  -> EC2 Mumbai
  |
  +---- Secondary Endpoint -> EC2 N. Virginia
  |
  +---- Weighted Routing
  |
  +---- Failover Routing + Health Check
```

### 1. DNS and Domain Preparation

A learner-owned public domain is used for the practical.

The authoritative DNS provider was identified first because DNS records must be created at the provider currently serving the domain.

Important DNS records used in the lab:

| Purpose | Record | Destination |
|---|---|---|
| ACM validation | CNAME | ACM `acm-validations.aws` target |
| CloudFront hostname | CNAME/Alias | CloudFront distribution |
| Route 53 delegation | NS | Route 53 hosted-zone name servers |
| Endpoint routing | A | EC2 endpoint IPs |

The ACM validation record and the application record are separate records.

### 2. ACM Certificate

ACM was requested in:

```text
Region: us-east-1
Certificate type: Public
Domain: <CDN-NAME>
Validation: DNS
Key algorithm: RSA 2048
```

The ACM-generated CNAME was added to the authoritative DNS provider.

Validation was confirmed only after the record became publicly resolvable and the certificate reached:

```text
Issued
```

The ACM validation CNAME was retained for managed certificate renewal.

### 3. Regional EC2 Endpoints

Two temporary HTTP endpoints were created:

| Endpoint | Region | Purpose |
|---|---|---|
| Primary | `ap-south-1` Mumbai | Primary application |
| Secondary | `us-east-1` N. Virginia | Secondary/failover application |

Each endpoint runs Nginx and serves a page identifying its Region.

Security Groups allow HTTP TCP/80 as required for the lab. SSH was not opened globally.

### 4. Private S3 Origin

An S3 bucket was created in Mumbai with:

- Block Public Access enabled.
- Bucket owner enforced.
- Versioning enabled.
- Default encryption enabled.
- Static website hosting disabled.

The S3 object was intentionally kept private.

Expected behavior:

```text
Direct S3 object access       -> 403 AccessDenied
CloudFront access             -> 200 / application content
```

This demonstrates that CloudFront, rather than the public S3 endpoint, is the intended access path.

### 5. CloudFront and OAC

A CloudFront distribution was created with:

```text
Origin: S3 REST endpoint
Origin access: Origin Access Control
Viewer protocol: HTTP -> HTTPS redirect
Methods: GET, HEAD
Cache policy: CachingOptimized
Compression: Enabled
Default root object: index.html
```

The S3 bucket policy was checked to ensure CloudFront could read objects through the distribution.

The important security relationship is:

```text
Internet
   |
   v
CloudFront
   |
   | OAC
   v
Private S3
```

The S3 bucket is not exposed as a public website.

### 6. Cache Behavior and Invalidation

The same object was requested multiple times using `curl`.

Relevant CloudFront headers were checked:

- `X-Cache`
- `Age`
- `Via`
- `X-Amz-Cf-Pop`

The page content was changed from Version 1 to Version 2.

Because the old object can remain cached, a CloudFront invalidation was created for:

```text
/index.html
```

After invalidation completed, Version 2 was verified.

### 7. CloudFront Signed URL

A CloudFront public/private key pair was generated for the lab.

The private key was kept secret and was not uploaded to GitHub or published.

A key group was configured and the following behavior was protected:

```text
/private/*
```

Expected results:

```text
Without signed URL     -> 403
Valid signed URL       -> 200
After URL expiry       -> 403
```

The signed URL was configured with a short expiry time.

### 8. Custom HTTPS Domain

After ACM reached `Issued`, the certificate was attached to CloudFront.

The custom hostname was configured as an alternate domain name.

DNS was then configured to point the custom hostname to CloudFront.

Validation included:

```bash
dig CNAME <CDN-NAME> +short
curl -I "https://<CDN-NAME>/"
```

The final HTTPS endpoint was expected to:

- Resolve to the CloudFront path.
- Return a successful HTTP response.
- Present a certificate covering the custom hostname.

### 9. Route 53 Routing Policies

The Route 53 portion demonstrated multiple routing concepts.

#### Simple Routing

```text
primary.<LAB-ZONE>   -> Mumbai EC2
secondary.<LAB-ZONE> -> N. Virginia EC2
```

#### Weighted Routing

Traffic was distributed between endpoints using configured weights.

This demonstrates controlled traffic distribution and can be useful for staged migrations or traffic splitting.

#### Failover Routing

A health check monitored the primary endpoint.

Conceptually:

```text
Primary Healthy
      |
      v
Primary endpoint

Primary Unhealthy
      |
      v
Secondary endpoint
```

The health check was tested by making the primary application unavailable and observing the routing behavior.

### 10. WAF

AWS WAF was evaluated with the CloudFront distribution.

The WAF configuration was kept within the lab scope and tested safely without intentionally generating harmful traffic.

### Day 15 Validation

- [x] ACM certificate requested in `us-east-1`
- [x] DNS validation completed
- [x] Certificate reached `Issued`
- [x] Private S3 bucket created
- [x] S3 public access blocked
- [x] CloudFront distribution created
- [x] OAC configured
- [x] Direct S3 access denied
- [x] CloudFront access verified
- [x] Cache headers inspected
- [x] Invalidation completed
- [x] Signed URL protection tested
- [x] Custom HTTPS hostname configured
- [x] Route 53 records and health checks tested
- [x] Routing/failover behavior validated
- [x] WAF configuration tested

---

# Day 16 — Cross-Region EC2 Backup & Disaster Recovery

## Objective

Create a disposable Mumbai workload, protect it using AWS Backup, copy the recovery point to N. Virginia, restore a new EC2 instance there, and validate the recovered application.

The selected DR strategy is:

```text
Backup and Restore
```

The lab demonstrates that a backup is not the same thing as a working disaster-recovery environment. Recovery must include restore, configuration, application validation, and—if required—traffic cutover.

## Day 16 Architecture Flow

```text
Mumbai - ap-south-1
-------------------

EC2 Primary
    |
    v
Encrypted EBS
    |
    v
AWS Backup
    |
    v
Primary Backup Vault
    |
    | Cross-Region Copy
    v

N. Virginia - us-east-1
-----------------------

Destination KMS Key
    |
    v
DR Backup Vault
    |
    v
Copied Recovery Point
    |
    v
Restore EC2
    |
    v
Application Validation
```

## 1. Recovery Design

The recovery design records:

```text
DR Strategy: Backup and Restore
RTO: <recorded target>
RPO: <recorded target>
Primary Region: ap-south-1
DR Region: us-east-1
```

RTO and RPO are measured from actual recorded UTC milestones rather than assumed from backup completion.

## 2. Mumbai Source Workload

A small Amazon Linux 2023 EC2 instance was created in Mumbai.

Configuration included:

- Encrypted 8 GiB gp3 root volume.
- Dedicated Security Group.
- HTTP access limited to the required source.
- Public IPv4 only for the temporary lab.
- `Backup=Day16` tag.
- Nginx application.

The application exposes:

```text
/
/health
```

The page contains a synthetic recovery marker:

```text
DAY16
```

The application also displays the instance Region and instance ID using IMDSv2.

## 3. Recovery Region Preparation

N. Virginia (`us-east-1`) was prepared before creating the copy.

Checks included:

- EC2 On-Demand vCPU quota.
- VPC and subnet availability.
- Internet Gateway routing where required.
- Available subnet IP addresses.
- Public IPv4 behavior.
- Compatible EC2 architecture and instance type.

## 4. Destination KMS Key

A customer-managed symmetric KMS key was created in N. Virginia.

Alias:

```text
alias/<PREFIX>-day16-dr-backup-key
```

Key rotation was enabled.

The key was retained while destination recovery points depended on it.

## 5. Destination AWS Backup Vault

A DR backup vault was created in N. Virginia:

```text
<PREFIX>-day16-dr-vault
```

The destination KMS key was associated with the vault.

Vault Lock was intentionally not enabled because this was a disposable lab.

## 6. Source Recovery Point

An AWS Backup vault was created in Mumbai:

```text
<PREFIX>-day16-primary-vault
```

An on-demand EC2 backup was started.

The backup job was monitored until:

```text
Completed
```

The completed recovery point was then verified inside the source vault.

## 7. Cross-Region Recovery-Point Copy

The completed recovery point was copied from:

```text
ap-south-1
```

to:

```text
us-east-1
```

Destination:

```text
<PREFIX>-day16-dr-vault
```

The copy job was monitored until:

```text
Completed
```

The copied recovery point was then verified in the destination vault.

This is the point at which the cross-Region copy contributes to the DR RPO.

## 8. Failure Simulation

Instead of immediately terminating the source instance, the application failure was simulated safely by stopping Nginx:

```bash
sudo systemctl stop nginx
curl --max-time 5 http://localhost/health || true
```

The failure, detection, and recovery-declaration timestamps were recorded in UTC.

This preserved the source instance for comparison until the DR restore was validated.

## 9. Restore in N. Virginia

The copied recovery point was restored in N. Virginia.

The restore configuration included:

- Compatible small EC2 instance type.
- Target VPC.
- Target public subnet.
- DR Security Group.
- Approved IAM instance profile or none where unnecessary.
- Approved AWS Backup restore role.
- Existing key-pair behavior where applicable.

The restore created a new EC2 instance rather than moving or overwriting the source.

The restored instance was tagged:

```text
Name=<PREFIX>-day16-dr-restored
```

## 10. Application Recovery Validation

After restore, the following were checked:

```bash
curl -I http://localhost
curl http://localhost/health
```

The application page was also checked for:

```text
DR Recovery Successful
N. Virginia
us-east-1
Instance ID
DAY16
```

IMDSv2 was used to independently verify the restored Region and instance ID.

Important distinction:

```text
Backup Completed
      !=
Restore Completed
      !=
Application Ready
      !=
Traffic Cutover
```

All recovery stages must be validated separately.

## 11. RTO and RPO

Achieved RTO was calculated using the recorded UTC milestones:

```text
Detection
+ Declaration
+ Orchestration
+ Restore
+ Configuration
+ Validation
+ DNS Cutover (if used)
= Achieved RTO
```

Achieved RPO was calculated using:

```text
Incident Time
-
Latest Usable Copied Recovery Point Time
=
Achieved RPO
```

## 12. DR Design Decisions

The lab also compared the following concepts without unnecessarily provisioning billable connectivity resources:

| Requirement | Concept |
|---|---|
| Rapid encrypted hybrid connection | Site-to-Site VPN |
| Predictable high bandwidth | Direct Connect |
| Many VPC/VPN attachments | Transit Gateway |
| On-premises resolves AWS private names | Route 53 Resolver inbound endpoint |
| AWS forwards DNS queries to on-premises | Route 53 Resolver outbound endpoint |
| Private S3 access | S3 Gateway Endpoint |
| Private access to supported AWS APIs | Interface Endpoint |
| Lower-cost relaxed DR | Backup and Restore |
| Core services always running | Pilot Light |
| Reduced complete environment | Warm Standby |
| Both Regions serve traffic | Active-Active |

These services were treated as design/decision exercises where the lab explicitly avoided unnecessary billable resources.

## Day 16 Validation

- [x] Mumbai EC2 workload created
- [x] EBS encryption verified
- [x] Application and `/health` endpoint verified
- [x] Recovery-region capacity checked
- [x] Destination KMS key created
- [x] Destination backup vault created
- [x] Source recovery point completed
- [x] Cross-Region copy completed
- [x] Destination recovery point verified
- [x] Failure safely simulated
- [x] Recovery point restored in N. Virginia
- [x] Restored EC2 instance created
- [x] Restored application validated
- [x] Region and instance metadata verified
- [x] RTO/RPO calculation prepared
- [x] DR strategy decisions documented
- [x] Cleanup completed

---

# Key Learnings

### Day 15

- DNS records must be created at the authoritative DNS provider.
- ACM validation and application DNS records serve different purposes.
- CloudFront can securely access a private S3 bucket using OAC.
- Cache invalidation is required when cached content must be refreshed immediately.
- Signed URLs provide temporary authorization for protected CloudFront content.
- Route 53 health checks and routing policies can direct traffic based on endpoint health and routing rules.
- ACM certificates used by CloudFront must be in `us-east-1`.

### Day 16

- A backup alone does not prove disaster recovery.
- Cross-Region recovery requires a completed recovery-point copy.
- Encryption and KMS permissions must be considered across Regions.
- Restoring an EC2 instance creates a new workload; it does not simply move the source.
- Application validation must happen after restore.
- RTO and RPO should be calculated from real recovery timestamps.
- DNS failover does not perform backup, restore, configuration, or application validation.

---

# Cost & Cleanup

These labs can create AWS charges through resources such as:

- EC2 instances
- Public IPv4 addresses
- EBS volumes and snapshots
- AWS Backup storage and cross-Region copies
- KMS customer-managed keys
- Route 53 hosted zones and health checks
- CloudFront data transfer
- WAF usage

After validation, remove all disposable resources from both Regions.

Recommended cleanup order:

```text
Day 15
CloudFront / WAF
Route 53 records and health checks
EC2 instances
S3 objects
S3 bucket
ACM certificate
Route 53 hosted zone/delegation
CloudFront keys/key groups

Day 16
Restored EC2
Source EC2
Backup recovery points
Backup vaults
KMS key (schedule deletion after dependencies are removed)
Temporary Security Groups/resources
```

Do not delete a KMS key while retained recovery points still depend on it.

---

# Final Outcome

Week 8 demonstrates two complementary AWS capabilities:

```text
Day 15
DNS + CDN + HTTPS + Private Origin + Edge Security + Routing

Day 16
Backup + Encryption + Cross-Region Protection + Restore + DR Validation
```

The key architectural lesson is that **traffic management and disaster recovery solve different problems**:

- Route 53/CloudFront manage how users reach applications.
- AWS Backup protects recoverable application state.
- Cross-Region copy provides geographic recovery capability.
- Restore and validation turn a recovery point into a usable DR workload.
