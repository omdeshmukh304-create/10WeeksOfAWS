# Week 2 - Day 4: AWS Organizations, Service Control Policies (SCPs) & IAM Identity Center

## Name

Om Deshmukh

---

# Objective

The objective of this practical was to understand how AWS Organizations helps manage multiple AWS accounts from a single place. I also learned how Service Control Policies (SCPs) provide organization-wide guardrails and how IAM Identity Center enables centralized user access across AWS accounts.

---

# AWS Services Used

- AWS Organizations
- Service Control Policies (SCP)
- IAM Identity Center
- AWS STS
- AWS IAM

---

# Topics Practiced

- AWS Organizations
- Root and Management Account
- Member Accounts
- Organizational Units (OU)
- Service Control Policies (SCP)
- IAM Identity Center
- Permission Sets
- Temporary STS Sessions
- Multi-Account Governance

---

# What I Built

I created an AWS Organization with a dedicated member account and organized it inside an Organizational Unit (OU). I configured a Service Control Policy (SCP) to restrict S3 bucket creation and used IAM Identity Center to provide centralized access through Permission Sets.

---

# Architecture

```text
AWS Organization
        │
        ▼
      Root
        │
 ┌──────┴────────┐
 │               │
Management    Dev-Env OU
 Account          │
                  ▼
          Member Account
                  │
        IAM Identity Center
                  │
          Permission Set
                  │
           Temporary STS Access
```

---

# Practical Steps

## Step 1 – Create an AWS Organization

- Created an AWS Organization.
- Verified the Management Account.

---

## Step 2 – Create a Member Account

- Added a new member account.
- Verified it was successfully created.

---

## Step 3 – Create an Organizational Unit (OU)

- Created an Organizational Unit named for the development environment.
- Moved the member account into the OU.

---

## Step 4 – Create a Service Control Policy

Created an SCP to deny S3 bucket creation.

Attached the SCP to the Development OU.

---

## Step 5 – Verify SCP

Attempted to create a new S3 bucket from the member account.

Result:

- Request failed with **AccessDenied** because the SCP explicitly denied the action.

---

## Step 6 – Configure IAM Identity Center

- Enabled IAM Identity Center.
- Created a user.
- Created a Permission Set.
- Assigned the Permission Set to the AWS account.

---

## Step 7 – Access AWS Account

- Logged in using the AWS Access Portal.
- Verified access using temporary AWS STS credentials.

---

# Key Concepts

## AWS Organizations

AWS Organizations allows multiple AWS accounts to be centrally managed with unified governance, security, and billing.

---

## Management Account

The Management Account is responsible for managing all member accounts within the organization.

---

## Member Account

A Member Account is used to isolate workloads such as development, testing, and production while remaining under centralized governance.

---

## Organizational Unit (OU)

An Organizational Unit groups AWS accounts so that policies can be applied collectively.

---

## Service Control Policy (SCP)

An SCP defines the maximum permissions available to AWS accounts within an Organization.

Unlike IAM policies, SCPs do not grant permissions—they only restrict them.

---

## IAM Identity Center

IAM Identity Center provides centralized user authentication and authorization across multiple AWS accounts using Permission Sets.

---

## Permission Set

A Permission Set is a collection of IAM permissions assigned to users through IAM Identity Center.

---

## AWS STS

AWS Security Token Service (STS) issues temporary credentials when users sign in through IAM Identity Center.

---

# Difference Between IAM Policy and SCP

| IAM Policy | SCP |
|------------|-----|
| Grants permissions | Restricts maximum permissions |
| Applied to Users, Groups, and Roles | Applied to AWS Accounts and OUs |
| Works within an account | Works across the entire Organization |
| Cannot override an SCP | Overrides IAM permissions if explicitly denied |

---

# What I Learned

- AWS Organizations simplifies multi-account management.
- Organizational Units help organize AWS accounts logically.
- SCPs enforce security guardrails across accounts.
- IAM Identity Center centralizes user access management.
- AWS STS provides secure temporary credentials.
- Enterprise AWS environments use these services to improve governance and security.

---

# Real-World Use Cases

- Managing Development, Testing, and Production accounts.
- Centralized access management for employees.
- Organization-wide security controls.
- Enforcing compliance policies.
- Restricting risky AWS operations.

---

# Challenges Faced

Understanding the difference between IAM Policies and Service Control Policies was initially confusing. After testing both, it became clear that IAM Policies grant permissions while SCPs define the maximum permissions allowed within an AWS Organization.

---

# Cleanup

After completing the practical:

- Removed the Service Control Policy.
- Deleted the Organizational Unit.
- Deleted the member account (or moved it back to Root before cleanup).
- Removed IAM Identity Center users and Permission Sets.
- Verified that no unnecessary AWS resources remained.

---

# Key Takeaway

AWS Organizations, Service Control Policies, and IAM Identity Center are essential services for managing large-scale AWS environments securely. They help organizations enforce governance, simplify access management, and improve overall cloud security.

---

# LinkedIn Post

(Add your LinkedIn post URL here)
