# CIDR Plan

## Objective

The objective of this CIDR plan is to create a simple, non-overlapping IP addressing scheme for two VPCs connected using VPC Peering while supporting private networking, NAT Gateway, and an Amazon S3 Gateway Endpoint.

---

# VPC Address Space

| Resource | CIDR Block | Purpose |
|----------|------------|---------|
| VPC-A | 10.0.0.0/16 | Primary application VPC |
| VPC-B | 10.1.0.0/16 | Secondary VPC for peering |

The CIDR ranges do not overlap, allowing successful VPC Peering.

---

# VPC-A Subnets

| Subnet | CIDR Block | Type | Purpose |
|---------|------------|------|---------|
| Public Subnet | 10.0.1.0/24 | Public | Bastion Host and NAT Gateway |
| Private Subnet | 10.0.2.0/24 | Private | Private EC2 Instance |

---

# VPC-B Subnets

| Subnet | CIDR Block | Type | Purpose |
|---------|------------|------|---------|
| Public Subnet | 10.1.1.0/24 | Public | Web Server EC2 |

---

# Route Design

## Public Route Table

Destination | Target
----------- | ------
10.0.0.0/16 | Local
0.0.0.0/0 | Internet Gateway

Used by:

- Public Subnet
- Bastion Host
- NAT Gateway

---

## Private Route Table

Destination | Target
----------- | ------
10.0.0.0/16 | Local
0.0.0.0/0 | NAT Gateway
S3 Prefix List | Gateway VPC Endpoint
10.1.0.0/16 | VPC Peering Connection

Used by:

- Private EC2

---

## VPC-B Route Table

Destination | Target
----------- | ------
10.1.0.0/16 | Local
0.0.0.0/0 | Internet Gateway
10.0.0.0/16 | VPC Peering Connection

---

# CIDR Planning Decisions

- Separate /16 CIDR blocks were used for each VPC.
- /24 subnets provide sufficient IP addresses for the lab.
- Public and Private workloads are isolated into separate subnets.
- CIDR ranges do not overlap.
- Route tables control internet access and inter-VPC communication.

---

# Network Flow

Internet
↓
Internet Gateway
↓
Public Subnet
(Bastion Host + NAT Gateway)
↓
Private Subnet
(Private EC2)
↓
Gateway Endpoint
Amazon S3

Private EC2
↓
VPC Peering
↓
VPC-B Web Server

---

# Benefits

- Clear network segmentation
- Secure private workloads
- Controlled outbound internet access
- Private S3 access without using the internet
- Secure communication between VPCs
- Easy to scale for future subnets and services
