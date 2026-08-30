# AWS S3 Advanced Storage Lab — Documentation

## 1. Objective

This lab demonstrates Amazon S3 data protection, lifecycle management, secure temporary access, encryption, and bucket-to-bucket replication using the AWS Management Console.

## 2. Resources Used

- Source bucket: `cloudadhar-s3-day11-gu-0808`
- Object Lock bucket: `cloudadhar-s3-day11-lock-0808`
- Replica bucket: `cloudadhar-s3-replica-0808`
- KMS customer managed key alias: `cloudadhar-s3-day11`
- Replication rule: `s3-replication-demo`
- Lifecycle rules shown: `s3-lifecycle-demo` and `logs-transition-and-cleanup`

---

## 3. Presigned URL

A presigned URL was successfully generated for `presigned-demo.txt`.

The S3 console confirmed that the URL was created and copied to the clipboard.

**Why?**  
A presigned URL provides temporary access to an S3 object without making the bucket public.

![alt text](<WhatsApp Image 2026-08-26 at 8.53.39 PM.jpeg>)

---

## 4. Object Lock and Legal Hold

The object `retention-demo.txt.txt` was stored under the `lock/` prefix.

An attempted deletion failed with **Access denied**. The S3 console explains that deleting objects from an Object-Lock-enabled bucket requires the appropriate bypass governance permission when governance retention applies.

The object was displayed with version information and a delete marker.

Its Object Lock details showed:

- **Legal hold:** Enabled
- **Retention mode:** Disabled

The legal hold was successfully edited, demonstrating explicit hold management.

![alt text](<WhatsApp Image 2026-08-26 at 9.01.05 PM (8).jpeg>)

![alt text](<WhatsApp Image 2026-08-26 at 9.02.28 PM.jpeg>)

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM.jpeg>)

---

## 5. Lifecycle Management

Lifecycle rules were configured to automate storage management.

One rule targets the `logs/` prefix and enables transition of current object versions between storage classes.

Another rule, `s3-lifecycle-demo`, is configured for all objects and has the current-version transition action enabled.

The console also shows:

- Lifecycle transitions can incur request charges.
- Objects smaller than 128 KB are not transitioned by default across storage classes.

**Why?**  
Lifecycle rules help automate storage-class movement and manage storage costs as objects age.

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM (3).jpeg>)

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM (4).jpeg>)
---

## 6. S3 Replication

The replication configuration was successfully updated.

- **Source bucket:** `cloudadhar-s3-day11-gu-0808`
- **Source region:** Asia Pacific (Mumbai), `ap-south-1`
- **Destination bucket:** `cloudadhar-s3-replica-0808`
- **Replication rule:** `s3-replication-demo`
- **Status:** Enabled
- **Scope:** Entire bucket
- **Storage class:** Same as source
- **Replica owner:** Same as source

**Why?**  
S3 Replication asynchronously copies objects from a source bucket to a configured destination bucket.

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM (1).jpeg>)

---

## 7. KMS Encryption

AWS KMS shows a customer managed symmetric key with alias:

`cloudadhar-s3-day11`

The key status is **Enabled**.

**Why?**  
Customer managed KMS keys provide controlled encryption-key management for workloads that require customer-level key administration.

**Screenshot 8 — Enabled customer managed KMS key.**

---

## 8. Replica Bucket Verification

The destination bucket `cloudadhar-s3-replica-0808` contains objects including:

- `private-report.txt`
- `replication-test.txt.txt`
- `copied/`

This provides console evidence of data present in the replica bucket.

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM (2).jpeg>)

---

## 9. Final Source Bucket Structure

The source bucket view shows:

- `documents/`
- `logs/`
- `presigned/`
- `storage/`
- `versions/`
- `replication-test.txt.txt`

![alt text](<WhatsApp Image 2026-08-26 at 9.03.39 PM (3)-1.jpeg>)

---

## 10. Key Learnings

- Object Lock protects object versions against deletion or overwrite according to the configured protection.
- Legal Hold can keep an object protected until the hold is explicitly removed.
- Versioning is fundamental to Object Lock workflows.
- Presigned URLs provide temporary object access without public bucket access.
- Lifecycle rules automate storage-class transitions and object management.
- S3 Replication asynchronously copies objects to a configured destination bucket.
- KMS customer managed keys provide controlled encryption-key management.

---


