# Day 12 — AWS S3 Replication & Lifecycle Management Lab

## 1. Objective

This lab demonstrates practical Amazon S3 **Replication** and **Lifecycle Management** using the AWS Management Console.

The lab covers:

- Cross-Region Replication (CRR)
- Same-Region Replication (SRR)
- Replication rules using object prefixes
- Verification of replicated objects in destination buckets
- S3 Lifecycle configuration
- Automatic cleanup of expired delete markers
- Automatic cleanup of incomplete multipart uploads

---

## 2. Resources Used

### Source Bucket
`cloudadhar-day12-rep-source-660119433125-ap-south-1-an`

### Destination Buckets
- `cloudadhar-day12-crr-dest-660119433125-ap-southeast-1-an`
- `cloudadhar-day12-srr-dest-660119433125-ap-south-1-an`

### Replication Rules
- `crr-prefix-rule` — prefix: `crr/`
- `srr-prefix-rule` — prefix: `srr/`

### Lifecycle Rule
`abort-incomplete-multipart-uploads`

---

## 3. Cross-Region Replication (CRR)

Cross-Region Replication copies selected S3 objects from a source bucket in one AWS Region to a destination bucket in another Region.

In this lab:

- Source Region: **Asia Pacific (Mumbai) — `ap-south-1`**
- Destination Region: **Asia Pacific (Singapore) — `ap-southeast-1`**
- Rule: `crr-prefix-rule`
- Prefix: `crr/`
- Status: **Enabled**
- Priority: **1**
- Storage class: **Same as source**

The source bucket contains an object under the `crr/` prefix after the replication rule was configured.

![alt text](<Screenshot 2026-08-29 154943.png>)

---

## 4. Same-Region Replication (SRR)

Same-Region Replication copies selected objects between S3 buckets that are located in the same AWS Region.

In this lab:

- Source Region: **Asia Pacific (Mumbai) — `ap-south-1`**
- Destination Region: **Asia Pacific (Mumbai) — `ap-south-1`**
- Rule: `srr-prefix-rule`
- Prefix: `srr/`
- Status: **Enabled**
- Priority: **0**
- Storage class: **Same as source**

The source `srr/` prefix was used to test the SRR rule.

![alt text](<Screenshot 2026-08-29 154334.png>)

## 5. Replication Rules Configuration

The S3 Replication Rules page confirms that the replication configuration was successfully updated.

Two rules are visible:

| Rule | Status | Scope | Destination |
|---|---|---|---|
| `crr-prefix-rule` | Enabled | Prefix `crr/` | Singapore (`ap-southeast-1`) |
| `srr-prefix-rule` | Enabled | Prefix `srr/` | Mumbai (`ap-south-1`) |

This demonstrates that different object prefixes can be routed to different destination buckets/Regions.

![alt text](<Screenshot 2026-08-29 154047.png>)

---

## 6. SRR Object Verification

The source `srr/` prefix was checked before/after the rule activity.

The screenshots show the objects used during the SRR test, including `before-rule.txt` and `after-rule.txt`.

![alt text](<Screenshot 2026-08-29 160233.png>)

---

## 7. CRR Destination Verification

The CRR destination bucket was checked under the `crr/` prefix.

The destination contains `after-rule.txt`, providing console evidence that the object reached the CRR destination.

![alt text](<Screenshot 2026-08-29 162531-1.png>)

---

## 8. SRR Destination Verification

The SRR destination bucket was checked under the `srr/` prefix.

The destination contains `after-rule.txt`, providing console evidence for the SRR test.

![alt text](<Screenshot 2026-08-29 160314.png>)

---

## 9. Lifecycle Management

S3 Lifecycle Management is used to automatically perform actions on objects as part of their lifecycle.

The source bucket's **Management → Lifecycle configuration** page shows the configured lifecycle rule.

The lab demonstrates lifecycle-based cleanup in addition to replication.

![alt text](<Screenshot 2026-08-29 174143.png>)

---

## 10. Lifecycle Rule — Abort Incomplete Multipart Uploads

The lifecycle rule:

`abort-incomplete-multipart-uploads`

is enabled for the **entire bucket**.

The rule was configured to:

- Delete expired object delete markers
- Abort incomplete multipart uploads
- Perform the multipart-upload cleanup after **7 days**

This prevents incomplete multipart uploads from remaining in the bucket unnecessarily.

![alt text](<Screenshot 2026-08-29 180723.png>)

---

## 11. Lifecycle Rule Details

The detailed lifecycle-rule page confirms:

- Rule name: `abort-incomplete-multipart-uploads`
- Status: **Enabled**
- Scope: **Entire bucket**
- No current-version transition actions defined
- No noncurrent-version actions defined
- Expired object delete markers: **Delete**
- Incomplete multipart uploads: **Delete after 7 days**

![Lifecycle rule details](09-lifecycle-rule-details.png)

**Screenshot 9 — Detailed lifecycle rule configuration.**

---

## 12. Why We Performed These Tasks

### CRR — Cross-Region Replication

CRR is useful when data needs to be replicated to another AWS Region for:

- Disaster recovery
- Regional redundancy
- Business continuity
- Lower-latency access in another geographic region

### SRR — Same-Region Replication

SRR is useful when copies of data are required within the same Region, for example for:

- Compliance requirements
- Separate buckets for different workloads
- Centralized copies
- Data processing or operational workflows

### Lifecycle Management

Lifecycle rules automate storage management and cleanup. They help reduce unnecessary storage usage and operational work by automatically handling objects or incomplete multipart uploads according to defined rules.

---

## 13. Key Learnings

- **CRR** replicates selected S3 objects to another AWS Region.
- **SRR** replicates selected S3 objects within the same AWS Region.
- Replication rules can be limited using an **object prefix**.
- Replication status and destinations can be verified from the S3 console.
- Destination buckets can be checked directly to verify replicated objects.
- **Lifecycle rules** automate object-management actions.
- Incomplete multipart uploads can be automatically removed after a configured period.
- Expired object delete markers can also be automatically deleted.

---

## 14. Final Completion Checklist

- [x] CRR replication rule created and enabled
- [x] SRR replication rule created and enabled
- [x] Prefix-based replication tested
- [x] CRR destination verified
- [x] SRR destination verified
- [x] Lifecycle configuration created
- [x] Expired delete-marker cleanup configured
- [x] Incomplete multipart upload cleanup configured for 7 days
- [x] Lifecycle rule verified from the details page
- [x] 9 screenshots included as lab evidence

---


# Conclusion

Day 12 successfully demonstrates **Amazon S3 Replication and Lifecycle Management** using practical AWS Console configuration and verification.

The lab provides evidence for both **Cross-Region Replication (CRR)** and **Same-Region Replication (SRR)**, along with lifecycle-based cleanup of expired delete markers and incomplete multipart uploads.
