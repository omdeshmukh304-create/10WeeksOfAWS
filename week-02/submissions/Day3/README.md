# Week 2 - Day 3: IAM Roles and AWS STS

## Name
Om Deshmukh

---

## Objective

The objective of this practical was to understand how IAM Roles and AWS Security Token Service (STS) work together to provide secure, temporary access to AWS resources without using permanent access keys.

---

## AWS Services Used

- Amazon EC2
- Amazon S3
- AWS IAM
- AWS STS
- AWS CLI

---

## Topics Practiced

- IAM Roles
- Trust Policy
- Permission Policy
- Instance Profile
- AWS STS
- Temporary Credentials
- Least Privilege Access

---

## What I Built

I created an IAM Role with a custom S3 Read-Only policy and attached it to an EC2 instance. Instead of storing AWS access keys, the EC2 instance automatically received temporary credentials through AWS STS. Using these credentials, the instance successfully accessed an S3 bucket while write operations were denied due to the least privilege policy.

---

## Architecture

```text
EC2 Instance
      │
      ▼
 IAM Role
      │
      ▼
 AWS STS
(Temporary Credentials)
      │
      ▼
Amazon S3 Bucket
(Read Only)
```

---

## Practical Steps

### Step 1 – Create a Test S3 Bucket

- Created a new S3 bucket.
- Uploaded a sample file (`day3-test.txt`).

---

### Step 2 – Create an IAM Role

- Selected **EC2** as the trusted entity.
- Created an IAM Role.
- Attached a custom S3 Read-Only policy.

---

### Step 3 – Attach Role to EC2

- Attached the IAM Role to the EC2 instance.
- Verified that the role was successfully attached.

---

### Step 4 – Verify Temporary Credentials

Executed the following command:

```bash
aws sts get-caller-identity
```

Result:

- Verified that the EC2 instance successfully assumed the IAM Role.
- Temporary credentials were provided automatically by AWS STS.

---

### Step 5 – Read Objects from Amazon S3

Listed bucket contents:

```bash
aws s3 ls s3://<bucket-name>
```

Read the uploaded object:

```bash
aws s3 cp s3://<bucket-name>/day3-test.txt -
```

Result:

- Successfully listed the bucket.
- Successfully downloaded the object.

---

### Step 6 – Verify Access Denied

Attempted to upload a file:

```bash
aws s3 cp test.txt s3://<bucket-name>/
```

Result:

```text
AccessDenied
```

The upload failed because the IAM Role did not have `s3:PutObject` permission.

---

## Allowed Test

- Successfully assumed the IAM Role using AWS STS.
- Successfully listed the S3 bucket.
- Successfully downloaded an object from the bucket.

---

## Denied Test

Uploading an object to Amazon S3 returned **AccessDenied** because the IAM Role only had read permissions. This confirmed that the Principle of Least Privilege was working correctly.

---

## Trust Policy vs Permission Policy

### Trust Policy

A Trust Policy defines **who is allowed to assume an IAM Role**.

In this practical, Amazon EC2 was allowed to assume the role.

### Permission Policy

A Permission Policy defines **what actions the IAM Role can perform** after it has been assumed.

In this practical, the role was allowed to:

- s3:ListBucket
- s3:GetObject

Write operations such as `s3:PutObject` were intentionally not allowed.

---

## What I Learned

- IAM Roles eliminate the need to store permanent AWS access keys.
- AWS STS provides temporary credentials automatically.
- Trust Policies and Permission Policies serve different purposes.
- Following the Principle of Least Privilege improves security.
- EC2 can securely access AWS services through IAM Roles.

---

## Challenge Faced

Initially, the EC2 instance was unable to access the S3 bucket because the required IAM permissions were not configured correctly. After attaching the correct policy, access worked as expected.

---

## Cleanup

After completing the practical:

- Deleted the test S3 bucket.
- Detached the IAM Role from the EC2 instance.
- Deleted the IAM Role.
- Deleted the Instance Profile.
- Terminated the EC2 instance.

---

## Screenshots
<img width="754" height="128" alt="image" src="https://github.com/user-attachments/assets/a6fe0aea-c2f1-4274-b471-372af17ea2c6" />



---

## LinkedIn Post

(Add your LinkedIn post URL here)

---

## Key Takeaway

Using IAM Roles together with AWS STS is the recommended and secure method for allowing AWS services to access AWS resources. Temporary credentials improve security by eliminating long-term access keys while the Principle of Least Privilege ensures that resources only receive the permissions they actually need.
