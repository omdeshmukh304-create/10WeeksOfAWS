# Day 7 – EC2, Golden AMI, IMDSv2 & Networking

Hands-on documentation for **Week 4 – Day 7 of #10WeeksOfAWS**.

This lab focused on practical Amazon EC2 operations, including:

- EC2 User Data
- Nginx installation and validation
- Golden AMI creation/use
- EC2 Instance Metadata Service v2 (IMDSv2)
- Token-based metadata access
- Tokenless metadata request validation
- Route table inspection and troubleshooting
- Identifying a `blackhole` default route

> **Publishing note:** Mask AWS account IDs, public/private IP addresses, instance IDs, AMI IDs, route-table IDs, gateway IDs, ARNs, tokens, credentials and other sensitive values before publishing screenshots.

---

## 1. EC2 User Data & Nginx

The EC2 instance was configured with **User Data** to install and configure Nginx automatically during first boot.

The resulting web page confirmed that Nginx was installed through EC2 User Data.

### Validation

The local web server was tested with:

```bash
curl http://localhost
```

The response returned:

```text
HTTP/1.1 200 OK
Server: nginx/...
```

This validated that the web server was running successfully.

### Evidence

![alt text](<WhatsApp Image 2026-08-13 at 10.50.32 PM.jpeg>)
---

## 2. Golden AMI

The configured EC2 environment was used as a **Golden AMI** baseline.

The purpose of a Golden AMI is to capture a known-good server configuration so that additional EC2 instances can be launched from a consistent image instead of configuring every server manually.

Typical flow:

```text
Base EC2
   |
   +-- User Data
   +-- Nginx
   +-- Configuration
   |
   v
Golden AMI
   |
   +----> New EC2 Instance
   |
   +----> New EC2 Instance
```

### Key benefit

**Consistency + faster provisioning + repeatable server configuration.**

---

## 3. EC2 Instance Metadata Service v2

The lab validated the security behavior of **IMDSv2**.

IMDSv2 requires a session token before metadata can be retrieved.

A token was requested using:

```bash
TOKEN=$(curl -s -X PUT   -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"   http://169.254.169.254/latest/api/token)
```

The token was then supplied to the metadata request:

```bash
curl -s   -H "X-aws-ec2-metadata-token: $TOKEN"   http://169.254.169.254/latest/meta-data/instance-id
```

The authenticated metadata request successfully returned the instance ID.

### Evidence

![alt text](<WhatsApp Image 2026-08-13 at 10.50.32 PM (2).jpeg>)

## 4. Tokenless Metadata Request – 401

A metadata request without the required IMDSv2 token was tested:

```bash
curl -s -o /dev/null -w 'IMDSv1 HTTP status: %{http_code}
' --max-time 3 http://169.254.169.254/latest/meta-data/instance-id
```

Result:

```text
IMDSv1 HTTP status: 401
```

This is the expected behavior when the instance requires IMDSv2.

### Why this matters

A `401 Unauthorized` response confirms that tokenless metadata access is blocked.

This provides evidence that the instance is enforcing the stronger IMDSv2 access model.

### Evidence

![alt text](<WhatsApp Image 2026-08-13 at 10.50.32 PM (1)-1.jpeg>)

---

## 5. IMDSv2 Security Flow

```text
EC2 Instance
     |
     | 1. PUT /latest/api/token
     |    X-aws-ec2-metadata-token-ttl-seconds
     v
IMDSv2
     |
     | 2. Session token
     v
EC2 Instance
     |
     | 3. GET metadata
     |    X-aws-ec2-metadata-token: <token>
     v
Metadata returned
```

Without the token:

```text
GET metadata
     |
     v
IMDSv2
     |
     v
401 Unauthorized
```

---

## 6. Route Table Troubleshooting

The route table was inspected during the networking troubleshooting workflow.

The route table contained:

```text
172.31.0.0/16  → local   → Active
0.0.0.0/0      → igw-... → Blackhole
```

The `blackhole` status on the default route indicates that the referenced target is no longer usable/reachable from the route table, commonly because the target resource was deleted or is otherwise invalid.

### Evidence

![alt text](<WhatsApp Image 2026-08-13 at 10.50.33 PM.jpeg>)

### Troubleshooting lesson

When an EC2 instance cannot reach the internet, inspect the path systematically:

```text
EC2
 |
 +-- Subnet
 |
 +-- Route Table
 |      |
 |      +-- 0.0.0.0/0 → Internet Gateway
 |
 +-- Security Group
 |
 +-- Network ACL
 |
 +-- Internet Gateway
```

A `blackhole` default route is an immediate indicator that the subnet's internet path needs investigation.

---

## 7. Requirement → AWS Choice → Reason

| Requirement | AWS choice | Reason |
|---|---|---|
| Automated first-boot configuration | EC2 User Data | Install/configure software automatically |
| Repeatable server baseline | Golden AMI | Launch consistent EC2 instances |
| Secure instance metadata | IMDSv2 | Requires session token |
| Validate metadata protection | Tokenless request → 401 | Confirms IMDSv2 enforcement |
| Internet connectivity | Route table + Internet Gateway | Provides default route |
| Network troubleshooting | Route table inspection | Identifies invalid/blackhole routes |

---

## 8. Key Takeaways

### EC2 User Data

User Data can automate initial instance configuration and software installation.

### Golden AMI

A Golden AMI provides a reusable, known-good EC2 server baseline.

### IMDSv2

IMDSv2 uses a session-oriented token flow and reduces exposure to certain metadata-access risks.

### 401 Validation

A tokenless metadata request returning `401` is useful evidence that IMDSv2 enforcement is active.

### Route Tables

Always verify the subnet route table when troubleshooting EC2 connectivity.

A `blackhole` route should be treated as a broken route target that needs investigation.

---

## 9. Evidence Checklist

- [x] EC2 User Data installed Nginx
- [x] Nginx returned `HTTP/1.1 200 OK`
- [x] Golden AMI workflow documented
- [x] IMDSv2 token generated
- [x] Token-authenticated metadata request succeeded
- [x] Tokenless metadata request returned `401`
- [x] Route table inspected
- [x] `0.0.0.0/0` blackhole route identified

---

## 10. Screenshots

All screenshots included in this document are stored under:

```text
screenshots/
```

### Screenshot 1 — IMDSv2 tokenless request

![IMDSv2 401 validation](screenshots/01-imdsv2-tokenless-401.png)

### Screenshot 2 — Golden AMI / Nginx

![Nginx installed through User Data](screenshots/02-golden-ami-nginx.png)

### Screenshot 3 — IMDSv2 authenticated request

![IMDSv2 token authentication](screenshots/03-imdsv2-token-authenticated.png)

### Screenshot 4 — Route table troubleshooting

![Route table blackhole](screenshots/04-route-table-blackhole.png)

---

## AWS Services Used

- Amazon EC2
- EC2 User Data
- Amazon Machine Images (AMI)
- EC2 Instance Metadata Service v2
- Amazon VPC
- Route Tables
- Internet Gateway

---

**10 Weeks of AWS – Week 4, Day 7**

Hands-on learning focused on EC2 provisioning, reusable AMIs, metadata security and network troubleshooting.

#AWS #EC2 #AMI #IMDSv2 #AmazonVPC #CloudArchitecture #AWSLearning #DevOps #10WeeksOfAWS
