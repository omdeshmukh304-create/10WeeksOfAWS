# Week 1 Notes

## Day 1 – Cloud Foundations

### Topics Covered
- AWS Global Infrastructure
- Regions, Availability Zones, and Edge Locations
- Shared Responsibility Model
- Root User Best Practices

### Key Learnings
- A Region contains multiple Availability Zones.
- Deploying across multiple AZs improves High Availability.
- Edge Locations reduce latency using Amazon CloudFront.
- AWS secures the cloud, while customers secure resources in the cloud.

---

## Day 2 – IAM Basics

### Topics Covered
- IAM Users
- IAM Groups
- IAM Roles
- IAM Policies
- Principle of Least Privilege

### Key Learnings
- IAM controls who can access AWS resources.
- Users represent identities, Groups simplify permission management.
- Roles provide temporary access.
- Policies define permissions using JSON.
- Always grant only the permissions required for a task.

---

## Day 3 – Account Security

### Hands-on
- Enabled Root User MFA
- Created an AWS Budget

### Key Learnings
- MFA adds an extra layer of security to the Root User.
- Budget alerts help avoid unexpected AWS charges.
- Never share Access Keys, Secret Keys, MFA QR codes, or payment details.

---

## Day 4 – IAM Hands-on

### Hands-on
- Created IAM Users and Groups
- Attached AWS Managed Policies
- Created a Customer Managed S3 Read-Only Policy
- Tested allowed and denied permissions

### Key Learnings
- IAM Groups simplify permission management.
- Customer Managed Policies provide fine-grained access control.
- Least Privilege prevents unnecessary access to AWS resources.

---

## Day 5 – GitHub OIDC Challenge

### Hands-on
- Configured GitHub OIDC Provider
- Created an IAM Role
- Configured Trust Policy
- Authenticated GitHub Actions using AWS STS

### Key Learnings
- OIDC eliminates the need for long-lived AWS Access Keys.
- GitHub Actions securely access AWS using temporary credentials.
- AWS STS issues temporary credentials after successful authentication.

---

# Overall Learning

- Built a strong foundation in AWS Cloud and IAM.
- Understood authentication and authorization in AWS.
- Implemented security best practices using IAM and MFA.
- Learned secure GitHub Actions authentication using OIDC and AWS STS.
- Practiced the Principle of Least Privilege through hands-on labs.
