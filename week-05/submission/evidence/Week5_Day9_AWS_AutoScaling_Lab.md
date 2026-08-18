# Week 5 — Day 9: AWS Auto Scaling & Load Balancing Lab

## Overview

Today I built and tested an **ALB-backed EC2 Auto Scaling Group** using a versioned Launch Template.

The goal was to understand how **Application Load Balancer (ALB), Target Groups, EC2 Auto Scaling, and CloudWatch** work together to maintain availability and automatically adjust compute capacity based on workload.

---

## Architecture

```text
Internet
   |
   v
Application Load Balancer (Internet-facing)
   |
   v
Target Group (HTTP :80)
   |
   +-------------------+
   |                   |
   v                   v
EC2 - AZ-1          EC2 - AZ-3
t3.micro            t3.micro
   ^                   ^
   +---------+---------+
             |
             v
     Auto Scaling Group
       Min: 1 / Max: 2
             ^
             |
     CloudWatch Target
       Tracking: 50%
```
![alt text](<WhatsApp Image 2026-08-18 at 10.25.22 PM.jpeg>)
---

## AWS Services Used

- Amazon EC2
- Application Load Balancer (ALB)
- EC2 Auto Scaling Group
- Launch Template
- Target Group
- Amazon CloudWatch
- Ubuntu Server
- stress-ng for CPU load testing

---

# 1. Launch Template

Created a versioned Launch Template:

`cloudadhar-day9-lt`

Configuration:

- Instance type: `t3.micro`
- Ubuntu AMI
- Key pair configured
- Security Group configured
- Version: `1`

![alt text](<WhatsApp Image 2026-08-16 at 9.59.33 PM.jpeg>)

---

# 2. Application Load Balancer

Created an **internet-facing Application Load Balancer**:

`cloudadhar-day9-alb`

Configured across two Availability Zones:

- `ap-south-1a`
- `ap-south-1b`

Listener:

- HTTP :80

The ALB forwards incoming traffic to the Target Group.

![alt text](<WhatsApp Image 2026-08-16 at 9.59.33 PM (1).jpeg>)

---

# 3. Target Group

Created the Target Group:

`cloudadhar-day9-tg`

Configuration:

- Target type: Instance
- Protocol: HTTP
- Port: 80
- Health check enabled
- Healthy target verified

![alt text](<WhatsApp Image 2026-08-16 at 9.59.33 PM (2).jpeg>)

---

# 4. Auto Scaling Group

Created the Auto Scaling Group:

`cloudadhar-day9-asg`

| Setting | Value |
|---|---:|
| Minimum capacity | 1 |
| Desired capacity | 1 |
| Maximum capacity | 2 |
| Availability Zones | 2 |
| Instance type | t3.micro |

The ASG was connected to the Target Group so newly launched instances could receive ALB traffic after passing health checks.

![alt text](<WhatsApp Image 2026-08-16 at 9.59.50 PM.jpeg>)

---

# 5. CloudWatch Target Tracking Policy

Configured a **Target Tracking Scaling Policy**:

**Average CPU Utilization → 50% target**

Configuration:

- Policy type: Target Tracking
- Metric: Average CPU Utilization
- Target value: 50%
- Scale-out: Enabled
- Scale-in: Enabled


---

# 6. High CPU Load Test

Used `stress-ng` to generate CPU load:

```bash
nohup stress-ng --cpu 2 --cpu-load 95 --timeout 10m > /tmp/stress-ng.log 2>&1 &
```

The EC2 monitoring dashboard showed approximately **88.6% CPU utilization** during the test.



![alt text](<WhatsApp Image 2026-08-16 at 9.59.33 PM (3).jpeg>)
---

# 7. Scale-Out Test — 1 → 2 Instances

When CPU utilization increased above the target level, the Target Tracking policy triggered scaling.

```text
1 instance → 2 instances
```

The second EC2 instance was launched automatically.

![alt text](<WhatsApp Image 2026-08-16 at 9.59.33 PM (4).jpeg>)

---

# 8. Two Healthy Instances

After scale-out:

```text
Desired capacity: 2
Instances: 2
Health: Healthy
```

The instances were running across two Availability Zones.


---

# 9. Scale-In Test — 2 → 1 Instance

After stopping the CPU stress test:

```bash
pkill stress-ng
```

CPU utilization decreased and Auto Scaling eventually adjusted capacity:

```text
2 instances → 1 instance
```



---

# 10. ALB Application Test

Opened the ALB DNS name in the browser and verified that traffic reached the backend EC2 instance.

The page displayed:

- Instance ID
- Instance type
- Availability Zone
- Private IP
- Hostname

---

# Troubleshooting Lesson

Scale-in did not happen immediately after stopping the CPU test.

I checked:

1. Target Tracking policy
2. CloudWatch CPU metrics
3. Auto Scaling Activity History
4. Instance health

The policy had **scale-in enabled**, so I waited for CloudWatch evaluation and the scaling process to complete.

> Auto Scaling is metric-driven and scaling actions can take time. A correct configuration does not always mean an immediate scaling action.

---

# Scaling Flow

```text
Normal Load
    |
    v
1 EC2 Instance
    |
    | CPU increases
    v
CloudWatch detects high CPU
    |
    v
Target Tracking Policy
(Target = 50%)
    |
    v
Scale Out
1 → 2 Instances
    |
    | CPU load removed
    v
CPU decreases
    |
    v
CloudWatch evaluates metric
    |
    v
Scale In
2 → 1 Instance
```

---

# Key Learnings

- How an **Application Load Balancer** distributes HTTP traffic.
- How **Target Groups** perform health checks.
- How **Launch Templates** provide reusable EC2 configuration.
- How an **Auto Scaling Group** maintains desired capacity.
- How **CloudWatch Target Tracking** controls scaling using CPU utilization.
- How to test both **scale-out and scale-in**.
- Why scaling actions may take time.
- Why **multi-AZ deployment** improves availability.

---

# Production Improvements

For production, I would:

- Run EC2 instances in **private subnets**
- Keep the ALB in **public subnets**
- Enable **HTTPS/TLS**
- Use an **immutable image-based deployment**
- Use a hardened AMI instead of manual configuration
- Add CloudWatch alarms and monitoring
- Follow least-privilege IAM
- Use production-appropriate instance types

---

# Final Result

```text
ALB
 ↓
Target Group
 ↓
Auto Scaling Group
 ↓
EC2 Instances
 ↓
CloudWatch Target Tracking
```

Scaling successfully demonstrated:

```text
1 → 2  ✅ Scale-Out
2 → 1  ✅ Scale-In
```

---

# Evidence Checklist


# Day 9 Summary

**Week 5, Day 9 of #10WeeksOfAWS**

Built and tested an **ALB-backed EC2 Auto Scaling architecture** with CloudWatch Target Tracking. Successfully demonstrated automatic **scale-out from 1 → 2 instances** during high CPU load and **scale-in from 2 → 1** after the workload decreased.

This practical helped me understand how **ALB + Auto Scaling + CloudWatch** work together to maintain application availability while dynamically adjusting compute capacity based on demand.

#AWS #EC2 #AutoScaling #CloudArchitecture #CloudAdhar #TrainWithShubham
