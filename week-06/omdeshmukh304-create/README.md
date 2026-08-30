# Week 6 - Amazon S3 and Storage

## Learner
- Name: Om
- GitHub:
- LinkedIn:
- Primary Region: `ap-south-1` (Mumbai)

## Day 11
- Source-bucket security controls: Bucket Owner Enforced, ACLs disabled, Block Public Access enabled, versioning enabled, and SSE-S3 default encryption.
- Destination SSE-KMS and Bucket Key: Destination bucket used SSE-KMS with the Day 11 customer-managed KMS key and S3 Bucket Key enabled.
- Storage-class decisions: Standard was used for normal access; Intelligent-Tiering was reviewed/tested for data with changing access patterns. Small objects under 128 KB remain in the Intelligent-Tiering Frequent Access tier.
- Version and delete-marker recovery: Uploaded two versions of `versions/version-demo.txt`, verified different Version IDs, deleted the visible key to create a delete marker, then removed only the delete marker and recovered Version 2.
- Manual copy and encryption result: `documents/private-report.txt` was manually copied to the separate copy bucket; the destination object used SSE-KMS, the Day 11 customer-managed key, an independent version ID, and remained private.
- Normal URL denial: The normal S3 Object URL returned `AccessDenied` because the bucket/object remained private.
- Presigned URL result and expiry: A presigned GET was used for temporary private access without making the bucket public. The URL was kept private and access was limited by its expiry.
- Lifecycle rule: The lifecycle rule for the `logs/` scope was enabled with noncurrent-version transition to Standard-IA after 30 days, permanent deletion after 90 days, expired delete-marker cleanup, and incomplete multipart-upload cleanup after 7 days.
- Object Lock Legal Hold result: Legal Hold blocked permanent deletion of the protected object version; after Legal Hold was turned off, cleanup succeeded.
- Troubleshooting lesson: Troubleshooting should start with the relevant control: permissions/KMS for copy or encryption failures, BPA/policy for anonymous access, Version IDs/delete markers for recovery, lifecycle age for transitions, and Legal Holds/retention for locked objects.

## Day 12
- Source, SRR destination, and CRR destination Regions: Source = Mumbai (`ap-south-1`); SRR destination = Mumbai (`ap-south-1`); CRR destination = Tokyo (`ap-northeast-1`).
- SRR rule and version results: `srr-prefix-rule` was enabled for the `srr/` prefix and SRR Versions 1 and 2 reached the Mumbai destination.
- CRR rule and version results: `crr-prefix-rule` was enabled for the `crr/` prefix and CRR Versions 1 and 2 reached the Tokyo destination.
- Pre-rule object result: Pre-rule objects remained source-only because live replication is not retroactive.
- Unmatched-prefix result: `other/no-replication-demo.txt` matched no replication rule and remained source-only.
- Transfer Acceleration review: Transfer Acceleration was inspected/enabled on the source bucket; acceleration requires clients to use the accelerated endpoint.
- Multipart cleanup rule: `abort-incomplete-multipart-uploads` was created for incomplete multipart uploads after 7 days.
- EFS and FSx review: Existing EFS configuration was reviewed without creating a duplicate filesystem. FSx Windows File Server, Lustre, NetApp ONTAP, and OpenZFS options were reviewed without deployment.
- Hybrid-storage decisions: S3 File Gateway for cached NFS/SMB access to S3; Volume Gateway for cloud-backed iSCSI volumes; Tape Gateway for virtual backup tapes; DataSync for automated online movement; Snow Family for offline migration/edge compute; Transfer Family for managed SFTP/FTPS/FTP/AS2 into S3/EFS.
- Optional Compliance or website result: Not performed as part of the main Day 12 lab.

## Architecture Decision

Week 6 focused on choosing the right S3 and AWS storage control for the workload rather than treating all storage services as interchangeable. For the core S3 design, I kept the replication buckets private, enabled versioning, used SSE-S3 for the replication lab, and separated the source, Same-Region Replication (SRR), and Cross-Region Replication (CRR) destinations. SRR was appropriate when the replica remained in Mumbai, while CRR was used for the Tokyo destination. Prefix-based rules made the design predictable: objects under `srr/` went to the SRR destination, objects under `crr/` went to the CRR destination, and an object under `other/` matched no rule.

Versioning was important for recovery and replication validation. Uploading the same key again created a new version, allowing Version 1 and Version 2 to be tracked independently. The pre-rule objects demonstrated that live replication is not retroactive, so historical eligible objects would require a separate Batch Replication approach if they needed to be copied later.

For data movement, I would choose DataSync when an online, automated transfer is practical. Snow Family is more suitable when very large datasets, limited connectivity, or edge-processing requirements make physical transfer or edge compute preferable. Storage Gateway and Transfer Family solve different integration problems: Gateway provides familiar file, volume, or tape interfaces, while Transfer Family provides managed traditional file-transfer protocols into AWS storage.

Overall, the architecture balances availability, recovery, security, compatibility, transfer method, and cost while avoiding unnecessary paid services.

## Cleanup

- Source bucket and versions: To be completed after final evidence capture using the Week 6 cleanup procedure.
- Destination bucket and versions: To be completed after final evidence capture.
- Object Lock bucket and protected versions: Day 12 did not create an Object Lock Compliance bucket; verify any Day 11 Legal Hold resources are cleaned after evidence.
- Multipart uploads: Remove any remaining incomplete multipart uploads as required by the cleanup procedure.
- KMS key: Clean up the Day 11 customer-managed KMS key only after all dependent encrypted objects/resources are removed.
- Replication rules and IAM role: Remove the Day 12 replication rules and associated replication IAM role after evidence.
- Transfer Acceleration: Disable it after evidence if it is no longer required.
- Optional website and Compliance cleanup: Not applicable to the main Day 12 lab unless the optional Day 11 make-up tasks were performed.
- Public-access controls: Keep Block Public Access enabled and confirm no public bucket policy or ACL remains.

## Reflection

### 1. Which S3 control protects confidentiality, and which protects recovery?

Encryption protects confidentiality by making stored data unreadable without the required encryption permissions/keys. Versioning protects recovery by retaining previous object versions and allowing recovery from accidental overwrites or deletes. In the lab, SSE-S3 protected data at rest while versioning enabled the delete-marker recovery test.

### 2. Why is a presigned URL different from making a bucket public?

A presigned URL grants temporary, controlled access to a specific S3 object using a signed request. The bucket can remain private. Making a bucket public changes the access policy so anonymous users can access resources according to that policy. Therefore, a presigned URL is a limited sharing mechanism, not a public-bucket configuration.

### 3. Which storage-class or lifecycle decision is easiest to get wrong on cost?

Lifecycle transitions are easy to get wrong because moving objects between storage classes can introduce minimum-storage-duration requirements, transition charges, retrieval considerations, and unexpected costs if the data is accessed again. The lifecycle timing should match the real access pattern rather than being chosen only to reduce the displayed storage price.

### 4. Why did pre-rule objects remain only in the source?

The replication rules were created after those objects were uploaded. Live S3 replication is not retroactive, so the already-existing eligible objects were not automatically copied. The lab intentionally used these objects to prove this behavior. Existing objects would require a separate Batch Replication approach if they needed replication.

### 5. When would you choose DataSync instead of Snow Family?

I would choose DataSync when reliable network connectivity is available and I need automated online movement or synchronization between supported storage locations. I would choose Snow Family when the dataset is very large, network transfer would be impractical or too slow, or the workload also requires edge computing in a remote location.
