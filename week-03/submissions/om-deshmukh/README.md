# Week 3 - AWS Networking (Day 5 & Day 6)

## Objective

The objective of this project was to build a secure AWS networking environment using Amazon VPC. The focus was on creating private infrastructure, enabling secure outbound internet access, connecting VPCs through VPC Peering, and accessing Amazon S3 privately using a Gateway VPC Endpoint without exposing resources to the public internet.

---

# Final Architecture

## VPC-A

- Public Subnet
  - Bastion Host
  - NAT Gateway

- Private Subnet
  - Private EC2 Instance
  - Private Route Table

## VPC-B

- Public Subnet
  - Web Server (EC2)

---

# CIDR Plan

| Resource | CIDR |
|----------|------|
| VPC-A | 10.0.0.0/16 |
| Public Subnet | 10.0.1.0/24 |
| Private Subnet | 10.0.2.0/24 |
| VPC-B | 10.1.0.0/16 |
| Public Subnet | 10.1.1.0/24 |

---

# Subnet Classification

## Public Subnet

- Connected to Internet Gateway
- Used for Bastion Host
- Used for NAT Gateway

## Private Subnet

- No direct internet access
- Uses NAT Gateway for outbound traffic
- Hosts Private EC2

---

# NAT Gateway vs NAT Instance

## NAT Gateway

Advantages

- Fully managed service
- Highly available within Availability Zone
- Better performance
- No patching required

Disadvantages

- Higher cost

---

## NAT Instance

Advantages

- Lower cost
- More control

Disadvantages

- Manual maintenance
- Single point of failure
- Lower scalability

---

## Decision

NAT Gateway was selected because it is managed, reliable, and follows AWS best practices.

---

# Cost-Safe Lab Design

For this lab, only one NAT Gateway was created to reduce AWS cost.

Production environments should deploy one NAT Gateway in each Availability Zone for high availability.

---

# Security Group vs NACL

| Security Group | Network ACL |
|---------------|-------------|
| Stateful | Stateless |
| Instance Level | Subnet Level |
| Allow Rules Only | Allow and Deny Rules |
| Return traffic automatically allowed | Return traffic must be explicitly allowed |

---

# Stateful vs Stateless

Security Groups are stateful.

If inbound traffic is allowed, response traffic is automatically permitted.

Network ACLs are stateless.

Both inbound and outbound rules must explicitly allow communication.

---

# Ephemeral Return Ports

When an EC2 instance sends outbound traffic, AWS uses ephemeral ports (typically 1024–65535).

Security Groups automatically allow return traffic.

Network ACLs must explicitly allow ephemeral port ranges.

---

# Private EC2 Access

Private EC2 was accessed securely through a Bastion Host.

The Private EC2 had no public IP address.

Administrative access remained inside the VPC.

---

# Flow Logs

## ACCEPT

Observed successful communication between instances after correct Security Group and routing configuration.

## REJECT

Observed rejected traffic during Security Group/NACL testing.

Flow Logs clearly identified rejected packets.

---

# VPC Peering

A VPC Peering Connection was created between:

- VPC-A
- VPC-B

Routes were updated in both VPC route tables.

Private communication between EC2 instances succeeded without using the public internet.

HTTP validation returned a successful response.

---

# Amazon S3 Gateway Endpoint

An S3 Gateway Endpoint was created inside VPC-A.

The endpoint automatically added a Prefix List route to the private route table.

Private EC2 successfully read objects from Amazon S3 without internet access.

Write operations were intentionally denied according to the IAM policy.

---

# Gateway Endpoint vs Interface Endpoint

## Gateway Endpoint

- Used for Amazon S3
- Used for DynamoDB
- No hourly cost
- Simpler configuration

## Interface Endpoint

- Used for most AWS services
- Uses Elastic Network Interfaces
- Hourly pricing
- Supports PrivateLink

---

## Decision

Gateway Endpoint was selected because the requirement was secure private access to Amazon S3.

---

# VPC Peering vs Transit Gateway

## VPC Peering

Advantages

- Simple
- No additional gateway
- Suitable for small environments

Disadvantages

- Does not scale well for many VPCs

---

## Transit Gateway

Advantages

- Centralized routing
- Scalable
- Better for enterprise environments

Disadvantages

- Additional cost

---

## Decision

VPC Peering was selected because only two VPCs were connected.

---

# Troubleshooting Notes

- Corrected route table associations.
- Verified Security Group rules.
- Verified NACL entries.
- Confirmed NAT Gateway routing.
- Validated VPC Peering routes.
- Verified S3 Gateway Endpoint route.
- Tested Flow Logs for ACCEPT and REJECT traffic.

---

# Cleanup

All AWS resources created during the lab were deleted.

Verified cleanup included:

- EC2 Instances
- NAT Gateway
- Elastic IP
- VPC Peering Connection
- Gateway Endpoint
- Flow Logs
- Route Tables
- Security Groups
- Subnets
- VPCs

No unnecessary billable resources remained.

---

# Learning Outcome

This lab improved understanding of:

- Amazon VPC Design
- Public and Private Networking
- NAT Gateway
- Route Tables
- Security Groups
- Network ACLs
- Flow Logs
- VPC Peering
- Amazon S3 Gateway Endpoint
- Secure AWS Network Architecture
- Cost Optimization
- AWS Networking Best Practices