# Validation Commands

## Objective

The following AWS CLI and Linux commands were used to validate the networking configuration during the Week 3 lab.

---

# 1. Verify AWS Identity

```bash
aws sts get-caller-identity
```

Expected Result

- AWS account information is returned.
- AWS CLI credentials are working.

---

# 2. List VPCs

```bash
aws ec2 describe-vpcs
```

Expected Result

- VPC-A and VPC-B are displayed.

---

# 3. List Subnets

```bash
aws ec2 describe-subnets
```

Expected Result

- Public and Private subnets are displayed.

---

# 4. Verify Route Tables

```bash
aws ec2 describe-route-tables
```

Expected Result

- Public Route Table contains Internet Gateway.
- Private Route Table contains NAT Gateway.
- S3 Gateway Endpoint Prefix List route is present.
- Peering route is present.

---

# 5. Verify Internet Gateway

```bash
aws ec2 describe-internet-gateways
```

Expected Result

- Internet Gateway is attached to the VPC.

---

# 6. Verify NAT Gateway

```bash
aws ec2 describe-nat-gateways
```

Expected Result

- NAT Gateway state is Available.

---

# 7. Verify EC2 Instances

```bash
aws ec2 describe-instances
```

Expected Result

- Bastion Host is running.
- Private EC2 is running.
- Web Server in VPC-B is running.

---

# 8. Verify VPC Peering

```bash
aws ec2 describe-vpc-peering-connections
```

Expected Result

- Peering status is Active.

---

# 9. Verify VPC Endpoints

```bash
aws ec2 describe-vpc-endpoints
```

Expected Result

- S3 Gateway Endpoint exists.
- Endpoint state is Available.

---

# 10. Test Private Internet Access

```bash
curl https://aws.amazon.com
```

Expected Result

- Page loads successfully through the NAT Gateway.

---

# 11. Test Private HTTP Communication

```bash
curl http://<Private-IP-of-Web-Server>
```

Expected Result

- HTTP 200 OK response.
- Communication occurs through VPC Peering.

---

# 12. Test Amazon S3 Read Access

```bash
aws s3 ls s3://<bucket-name>
```

Expected Result

- Bucket contents are listed successfully.

---

# 13. Test Amazon S3 Object Download

```bash
aws s3 cp s3://<bucket-name>/<object-name> .
```

Expected Result

- Object downloads successfully using the S3 Gateway Endpoint.

---

# 14. Test Denied S3 Write

```bash
aws s3 cp test.txt s3://<bucket-name>/
```

Expected Result

- AccessDenied error is returned according to the IAM policy.

---

# 15. Verify VPC Flow Logs

```bash
aws ec2 describe-flow-logs
```

Expected Result

- Flow Logs are enabled.
- ACCEPT and REJECT records are generated.

---

# 16. Verify Security Group Rules

```bash
aws ec2 describe-security-groups
```

Expected Result

- Required inbound and outbound rules are configured.

---

# 17. Verify Network ACLs

```bash
aws ec2 describe-network-acls
```

Expected Result

- Allow/Deny rules are correctly configured.

---

# 18. Verify Route from Private EC2

```bash
ip route
```

Expected Result

- Default route points toward the private subnet configuration.

---

# 19. Verify Network Connectivity

```bash
ping <Private-IP>
```

Expected Result

- Successful communication between permitted instances.

---

# 20. Cleanup Validation

```bash
aws ec2 describe-vpcs
aws ec2 describe-nat-gateways
aws ec2 describe-vpc-endpoints
aws ec2 describe-vpc-peering-connections
```

Expected Result

- Resources created during the lab have been deleted.
- No unnecessary billable resources remain.

---

# Validation Summary

The networking environment was successfully validated for:

- VPC and subnet configuration
- Route tables
- Internet Gateway
- NAT Gateway
- Private EC2 outbound internet access
- Security Groups
- Network ACLs
- VPC Flow Logs
- VPC Peering
- Private HTTP communication
- Amazon S3 Gateway Endpoint
- Read-only S3 access
- IAM permission enforcement
- Cleanup verification
