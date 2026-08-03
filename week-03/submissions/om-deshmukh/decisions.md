# Design Decisions

## Overview

This document explains the key networking design decisions made during the Week 3 AWS Networking lab and the reasoning behind each choice.

---

# 1. Public and Private Subnets

## Decision

Separate Public and Private Subnets were created inside VPC-A.

## Reason

- Public resources require internet connectivity.
- Private resources should not be directly accessible from the internet.
- Improves security and follows AWS networking best practices.

---

# 2. Bastion Host

## Decision

A Bastion Host was deployed in the Public Subnet.

## Reason

- Provides secure administrative access to the Private EC2 instance.
- Prevents exposing the Private EC2 to the internet.
- Keeps management traffic within the VPC.

---

# 3. NAT Gateway

## Decision

A NAT Gateway was used instead of a NAT Instance.

## Reason

- Fully managed AWS service.
- High availability within an Availability Zone.
- Better performance and scalability.
- No operating system maintenance.

For cost optimization, only one NAT Gateway was deployed for this lab.

---

# 4. Route Table Design

## Decision

Separate Route Tables were used for Public and Private Subnets.

## Reason

Public Route Table

- Internet Gateway provides internet access.

Private Route Table

- NAT Gateway provides outbound internet access.
- No direct inbound internet connectivity.
- Includes routes for VPC Peering and the S3 Gateway Endpoint.

---

# 5. Security Groups

## Decision

Security Groups were used as the primary instance-level firewall.

## Reason

- Stateful filtering.
- Easier to manage.
- Automatically allows return traffic.
- Simple rule management.

---

# 6. Network ACLs

## Decision

Network ACLs were used for subnet-level traffic control and testing.

## Reason

- Demonstrates stateless filtering.
- Allows explicit Allow and Deny rules.
- Useful for additional network protection.

---

# 7. VPC Flow Logs

## Decision

Flow Logs were enabled.

## Reason

- Monitor network traffic.
- Troubleshoot connectivity issues.
- Observe ACCEPT and REJECT actions.
- Verify Security Group and NACL behavior.

---

# 8. VPC Peering

## Decision

VPC-A and VPC-B were connected using VPC Peering.

## Reason

- Simple private communication between two VPCs.
- No internet routing required.
- Lower cost than Transit Gateway for small environments.

---

# 9. Amazon S3 Gateway Endpoint

## Decision

A Gateway VPC Endpoint was created for Amazon S3.

## Reason

- Private access to S3.
- No internet or NAT Gateway required for S3 traffic.
- Lower cost than Interface Endpoints.
- Automatically updates the route table with an AWS Prefix List.

---

# 10. Gateway Endpoint vs Interface Endpoint

## Decision

Gateway Endpoint was selected.

## Reason

- Native support for Amazon S3.
- No hourly endpoint charges.
- Simpler architecture.
- Meets the project requirements.

---

# 11. VPC Peering vs Transit Gateway

## Decision

VPC Peering was selected.

## Reason

- Only two VPCs needed connectivity.
- Easy to configure.
- Cost-effective for small deployments.

Transit Gateway is more suitable for large enterprise environments with many VPCs.

---

# 12. Cost Optimization

## Decision

The environment was designed to minimize AWS costs.

## Actions Taken

- One NAT Gateway
- Small EC2 instances
- Limited number of VPC resources
- Cleanup after lab completion

---

# Final Outcome

The final architecture provides:

- Secure public and private network separation
- Controlled outbound internet access
- Secure management through a Bastion Host
- Private communication using VPC Peering
- Private Amazon S3 access using a Gateway Endpoint
- Network visibility with VPC Flow Logs
- A cost-effective networking design following AWS best practices