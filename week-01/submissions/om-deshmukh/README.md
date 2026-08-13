# Week 1 - AWS Cloud Foundations & IAM

## 👋 Introduction

In Week 1 of the **10 Weeks of AWS Challenge**, I focused on understanding the fundamentals of AWS Cloud and Identity & Access Management (IAM). Along with learning the concepts, I completed hands-on labs to secure my AWS account and implement IAM best practices.

---

## 🎯 Objectives

- Understand AWS Global Infrastructure
- Learn the Shared Responsibility Model
- Secure the AWS Account
- Practice IAM Users, Groups, Roles, and Policies
- Implement the Principle of Least Privilege
- Explore GitHub OIDC Authentication

---

## 🛠️ Hands-on Completed

### Day 1 – Cloud Foundations
- Learned about AWS Regions, Availability Zones, and Edge Locations
- Understood the AWS Shared Responsibility Model
- Learned Root User best practices

### Day 2 – IAM Basics
- Learned IAM Users, Groups, Roles, and Policies
- Understood AWS Managed Policies and Customer Managed Policies
- Learned the Principle of Least Privilege

### Day 3 – Account Security
- Enabled Multi-Factor Authentication (MFA) for the Root User
- Created an AWS Budget to monitor cloud spending

### Day 4 – IAM Hands-on
- Created IAM Users and Groups
- Attached AWS Managed Policies
- Created a Customer Managed S3 Read-Only Policy
- Verified allowed and denied permissions using Least Privilege

### Day 5 – GitHub OIDC Challenge
- Added GitHub as an OIDC Identity Provider
- Created an IAM Role for GitHub Actions
- Configured the Trust Policy
- Successfully authenticated GitHub Actions with AWS using OIDC
- Verified access using AWS STS and Amazon S3

---

## 📚 Key Learnings

- Identity + Permissions = Access
- Follow the Principle of Least Privilege
- Use IAM Roles instead of sharing credentials
- OIDC provides secure, temporary AWS credentials for GitHub Actions
- AWS STS eliminates the need for long-lived Access Keys in CI/CD pipelines

---

## 🚧 Challenges Faced

Initially, understanding the GitHub OIDC authentication flow and Trust Policy was challenging. After configuring the Identity Provider, IAM Role, and Trust Policy, I successfully authenticated GitHub Actions with AWS using temporary credentials.

---
## ✅ Week 1 Status
