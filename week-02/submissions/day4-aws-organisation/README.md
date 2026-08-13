# Week 2 - Day 4: AWS Organizations, SCPs and IAM Identity Center

## Name

Om Deshmukh

---

# Objective

The objective of this practical was to understand how AWS Organizations helps manage multiple AWS accounts from a single place, apply centralized governance using Service Control Policies (SCPs), and provide secure workforce access through IAM Identity Center.

---

# AWS Services Used

- AWS Organizations
- Organizational Units (OU)
- Service Control Policies (SCP)
- IAM Identity Center
- AWS STS
- Amazon S3
- AWS CloudShell

---

# Topics Practiced

- AWS Organizations
- Root and Management Account
- Member Account
- Organizational Unit (OU)
- Service Control Policy (SCP)
- IAM Identity Center
- Permission Sets
- Temporary STS Credentials
- Consolidated Billing
- Centralized Access Management

---

# Architecture

```
AWS Organization
│
├── Root
│   ├── CloudAdhar-Management
│   │   ├── Organizations Administration
│   │   ├── IAM Identity Center
│   │   └── Consolidated Billing
│   │
│   └── Dev-Env OU
│       ├── SCP
│       │   Deny S3 Bucket Creation
│       │
│       └── CloudAdhar-Dev
│
└── IAM Identity Center
    └── cloudadhar-demo
        └── CloudAdhar-Admin Permission Set
            └── Temporary STS Session
```

---

# What I Built

During this practical, I created an AWS Organization and added a member account.

An Organizational Unit (Dev-Env) was created, and a Service Control Policy (SCP) was attached to restrict S3 bucket creation.

I configured IAM Identity Center, created a user and a permission set, and assigned secure access to the member account using temporary STS credentials.

Finally, I verified that S3 bucket creation worked before moving the account into the OU and failed afterward because the SCP explicitly denied the action.

---

# Practical Steps

## Step 1

Created an AWS Organization.

Verified the Root and Management Account.

---

## Step 2

Created a Member Account.

```
CloudAdhar-Dev
```

---

## Step 3

Created an Organizational Unit.

```
Dev-Env
```

---

## Step 4

Created an SCP.

```
Deny S3 Bucket Creation
```

Attached the SCP to the Dev-Env OU.

---

## Step 5

Created an IAM Identity Center User.

```
cloudadhar-demo
```

Created a Permission Set.

```
CloudAdhar-Admin
```

Assigned the permission set to the member account.

---

## Step 6

Logged in through the AWS Access Portal.

Verified temporary credentials.

```bash
aws sts get-caller-identity
```

Result

Temporary STS credentials were successfully issued.

---

## Step 7

Created an S3 bucket before moving the account into the OU.

Result

```
Bucket Created Successfully
```

---

## Step 8

Moved the member account into the Dev-Env OU.

---

## Step 9

Attempted to create another S3 bucket.

Result

```
AccessDenied
```

The SCP explicitly denied the CreateBucket action.

---

# Important Concepts

## What is AWS Organization?

AWS Organizations is a service that allows multiple AWS accounts to be managed centrally with shared billing, governance, and security.

---

## What is Root?

The Root is the top-level container inside an AWS Organization.

All Organizational Units and Member Accounts exist under the Root.

---

## What is a Management Account?

The Management Account controls the AWS Organization.

It is responsible for:

- Creating member accounts
- Managing Organizational Units
- Managing SCPs
- Managing IAM Identity Center
- Consolidated Billing

---

## What is a Member Account?

A Member Account is an AWS account that belongs to the Organization.

Policies and governance are managed centrally from the Management Account.

---

## What is an Organizational Unit (OU)?

An OU is a logical container used to group AWS accounts.

SCPs can be attached to an OU so that every account inside the OU follows the same security rules.

---

## What is an SCP?

A Service Control Policy is a guardrail.

It **does not grant permissions.**

Instead, it defines the maximum permissions available to AWS accounts within the Organization.

Even if an IAM policy allows an action, the SCP can still deny it.

---

## Why IAM Identity Center?

IAM Identity Center provides centralized user access.

Instead of creating separate IAM users in every AWS account, users log in once and securely access multiple AWS accounts using temporary credentials.

Benefits:

- Centralized Identity Management
- Temporary Credentials
- Better Security
- Easier User Management

---

## Permission Set vs SCP

### Permission Set

Defines what a user is allowed to do after signing in through IAM Identity Center.

Example:

```
Allow s3:CreateBucket
```

---

### Service Control Policy

Defines the maximum permissions allowed within an AWS account.

Example:

```
Deny s3:CreateBucket
```

If both exist:

```
Permission Set
Allow CreateBucket

+

SCP
Deny CreateBucket

=

Final Result

DENY
```

---

# Why Bucket Creation Worked Before SCP

Initially, the CloudAdhar-Dev account was directly under the Root.

Since no SCP was attached, IAM permissions allowed bucket creation.

---

# Why Bucket Creation Failed After Moving into the OU

After moving the account into the Dev-Env OU, the attached SCP explicitly denied the CreateBucket action.

Even though the Permission Set allowed the operation, the SCP overrode it.

Result:

```
AccessDenied
```

---

# Consolidated Billing

AWS Organizations combines billing for all member accounts into the Management Account.

Benefits include:

- Single Invoice
- Centralized Cost Tracking
- Easier Cost Management
- Shared Billing Administration

---

# What I Learned

- AWS Organizations simplify multi-account management.
- SCPs act as organization-wide security guardrails.
- IAM Identity Center removes the need for duplicate IAM users.
- Permission Sets grant access, while SCPs define the maximum allowed permissions.
- AWS STS provides secure temporary credentials.
- Centralized billing makes managing multiple AWS accounts easier.

---

# Challenge Faced

Initially, I had difficulty understanding why S3 bucket creation failed even though my Permission Set allowed it.

After analyzing the SCP, I learned that an explicit deny in an SCP always overrides IAM permissions.

---

# Cleanup

After completing the practical, I cleaned up the environment by:

- Deleting the Organizational Unit
- Deleting the Service Control Policy
- Removing IAM Identity Center users and groups
- Deleting the test S3 bucket
- Removing unnecessary resources created during the lab

---
# Week 2 - Day 4: AWS Organizations, SCPs and IAM Identity Center

## Name

Om Deshmukh

---

# Objective

The objective of this practical was to understand how AWS Organizations helps manage multiple AWS accounts from a single place, apply centralized governance using Service Control Policies (SCPs), and provide secure workforce access through IAM Identity Center.

---

# AWS Services Used

- AWS Organizations
- Organizational Units (OU)
- Service Control Policies (SCP)
- IAM Identity Center
- AWS STS
- Amazon S3
- AWS CloudShell

---

# Topics Practiced

- AWS Organizations
- Root and Management Account
- Member Account
- Organizational Unit (OU)
- Service Control Policy (SCP)
- IAM Identity Center
- Permission Sets
- Temporary STS Credentials
- Consolidated Billing
- Centralized Access Management

---

# Architecture

```
AWS Organization
│
├── Root
│   ├── CloudAdhar-Management
│   │   ├── Organizations Administration
│   │   ├── IAM Identity Center
│   │   └── Consolidated Billing
│   │
│   └── Dev-Env OU
│       ├── SCP
│       │   Deny S3 Bucket Creation
│       │
│       └── CloudAdhar-Dev
│
└── IAM Identity Center
    └── cloudadhar-demo
        └── CloudAdhar-Admin Permission Set
            └── Temporary STS Session
```

---

# What I Built

During this practical, I created an AWS Organization and added a member account.

An Organizational Unit (Dev-Env) was created, and a Service Control Policy (SCP) was attached to restrict S3 bucket creation.

I configured IAM Identity Center, created a user and a permission set, and assigned secure access to the member account using temporary STS credentials.

Finally, I verified that S3 bucket creation worked before moving the account into the OU and failed afterward because the SCP explicitly denied the action.

---

# Practical Steps

## Step 1

Created an AWS Organization.

Verified the Root and Management Account.

---

## Step 2

Created a Member Account.

```
CloudAdhar-Dev
```

---

## Step 3

Created an Organizational Unit.

```
Dev-Env
```

---

## Step 4

Created an SCP.

```
Deny S3 Bucket Creation
```

Attached the SCP to the Dev-Env OU.

---

## Step 5

Created an IAM Identity Center User.

```
cloudadhar-demo
```

Created a Permission Set.

```
CloudAdhar-Admin
```

Assigned the permission set to the member account.

---

## Step 6

Logged in through the AWS Access Portal.

Verified temporary credentials.

```bash
aws sts get-caller-identity
```

Result

Temporary STS credentials were successfully issued.

---

## Step 7

Created an S3 bucket before moving the account into the OU.

Result

```
Bucket Created Successfully
```

---

## Step 8

Moved the member account into the Dev-Env OU.

---

## Step 9

Attempted to create another S3 bucket.

Result

```
AccessDenied
```

The SCP explicitly denied the CreateBucket action.

---

# Important Concepts

## What is AWS Organization?

AWS Organizations is a service that allows multiple AWS accounts to be managed centrally with shared billing, governance, and security.

---

## What is Root?

The Root is the top-level container inside an AWS Organization.

All Organizational Units and Member Accounts exist under the Root.

---

## What is a Management Account?

The Management Account controls the AWS Organization.

It is responsible for:

- Creating member accounts
- Managing Organizational Units
- Managing SCPs
- Managing IAM Identity Center
- Consolidated Billing

---

## What is a Member Account?

A Member Account is an AWS account that belongs to the Organization.

Policies and governance are managed centrally from the Management Account.

---

## What is an Organizational Unit (OU)?

An OU is a logical container used to group AWS accounts.

SCPs can be attached to an OU so that every account inside the OU follows the same security rules.

---

## What is an SCP?

A Service Control Policy is a guardrail.

It **does not grant permissions.**

Instead, it defines the maximum permissions available to AWS accounts within the Organization.

Even if an IAM policy allows an action, the SCP can still deny it.

---

## Why IAM Identity Center?

IAM Identity Center provides centralized user access.

Instead of creating separate IAM users in every AWS account, users log in once and securely access multiple AWS accounts using temporary credentials.

Benefits:

- Centralized Identity Management
- Temporary Credentials
- Better Security
- Easier User Management

---

## Permission Set vs SCP

### Permission Set

Defines what a user is allowed to do after signing in through IAM Identity Center.

Example:

```
Allow s3:CreateBucket
```

---

### Service Control Policy

Defines the maximum permissions allowed within an AWS account.

Example:

```
Deny s3:CreateBucket
```

If both exist:

```
Permission Set
Allow CreateBucket

+

SCP
Deny CreateBucket

=

Final Result

DENY
```

---

# Why Bucket Creation Worked Before SCP

Initially, the CloudAdhar-Dev account was directly under the Root.

Since no SCP was attached, IAM permissions allowed bucket creation.

---

# Why Bucket Creation Failed After Moving into the OU

After moving the account into the Dev-Env OU, the attached SCP explicitly denied the CreateBucket action.

Even though the Permission Set allowed the operation, the SCP overrode it.

Result:

```
AccessDenied
```

---

# Consolidated Billing

AWS Organizations combines billing for all member accounts into the Management Account.

Benefits include:

- Single Invoice
- Centralized Cost Tracking
- Easier Cost Management
- Shared Billing Administration

---

# What I Learned

- AWS Organizations simplify multi-account management.
- SCPs act as organization-wide security guardrails.
- IAM Identity Center removes the need for duplicate IAM users.
- Permission Sets grant access, while SCPs define the maximum allowed permissions.
- AWS STS provides secure temporary credentials.
- Centralized billing makes managing multiple AWS accounts easier.

---

# Challenge Faced

Initially, I had difficulty understanding why S3 bucket creation failed even though my Permission Set allowed it.

After analyzing the SCP, I learned that an explicit deny in an SCP always overrides IAM permissions.

---

# Cleanup

After completing the practical, I cleaned up the environment by:

- Deleting the Organizational Unit
- Deleting the Service Control Policy
- Removing IAM Identity Center users and groups
- Deleting the test S3 bucket
- Removing unnecessary resources created during the lab

---

# Screenshots
<img width="890" height="601" alt="image" src="https://github.com/user-attachments/assets/37957d1c-d4bd-47fb-9d4d-1ae5e52c43da" />
<img width="890" height="601" alt="image" src="https://github.com/user-attachments/assets/33a52e3b-3cfc-4b6a-8213-528a68084876" />
<img width="952" height="852" alt="image" src="https://github.com/user-attachments/assets/ad37201e-c146-46ab-ba23-68c1f8144e1e" />

---



# Key Takeaway

AWS Organizations, Service Control Policies, and IAM Identity Center together provide centralized governance, secure access management, and scalable multi-account administration. SCPs act as security guardrails, while IAM Identity Center simplifies user access using temporary AWS STS credentials.

---



 Key Takeaway

AWS Organizations, Service Control Policies, and IAM Identity Center together provide centralized governance, secure access management, and scalable multi-account administration. SCPs act as security guardrails, while IAM Identity Center simplifies user access using temporary AWS STS credentials.
