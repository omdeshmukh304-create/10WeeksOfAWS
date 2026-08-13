# Week 2 - Day 2: AWS WAF (Web Application Firewall)

## Name

Om Deshmukh

---

# Objective

The objective of this practical was to understand how AWS WAF helps protect web applications by filtering and monitoring incoming HTTP and HTTPS requests. I learned how security rules can be used to block unwanted traffic before it reaches an application.

---

# AWS Services Used

- AWS WAF
- AWS Console

---

# Topics Practiced

- Introduction to AWS WAF
- Web ACL
- Rules and Rule Groups
- Managed Rules
- Custom Rules
- Allow, Block and Count Actions
- Basic Web Application Security

---

# What I Learned

AWS WAF is a web application firewall that protects applications from common web attacks such as SQL Injection, Cross-Site Scripting (XSS), and malicious bots.

Instead of modifying the application code, security rules can be configured in AWS WAF to inspect incoming requests and decide whether they should be allowed, blocked, or counted.

---

# Practical Steps

## Step 1

Explored AWS WAF from the AWS Management Console.

---

## Step 2

Learned about Web ACLs and how they are attached to AWS resources.

---

## Step 3

Understood the difference between Managed Rules and Custom Rules.

- Managed Rules are maintained by AWS.
- Custom Rules are created based on application requirements.

---

## Step 4

Explored different rule actions:

- Allow
- Block
- Count

---

## Step 5

Learned how AWS WAF evaluates requests before forwarding them to the application.

---

# Key Concepts

## What is AWS WAF?

AWS WAF is a managed security service that protects web applications from common web exploits and malicious traffic.

---

## What is a Web ACL?

A Web ACL is a collection of rules that determines how incoming web requests should be handled.

---

## Managed Rules

Managed Rules are preconfigured security rules provided by AWS that help protect against common threats.

---

## Custom Rules

Custom Rules allow organizations to create security policies based on their own application requirements.

---

## Rule Actions

### Allow

Permits the request to reach the application.

### Block

Stops the request before it reaches the application.

### Count

Records the request without blocking it, which helps in monitoring and testing.

---

# Benefits of AWS WAF

- Protects against common web attacks
- Improves application security
- Reduces unwanted traffic
- Easy integration with AWS services
- Managed by AWS

---

# Real-World Use Cases

- Protecting company websites
- Securing APIs
- Blocking malicious bots
- Preventing SQL Injection attacks
- Preventing Cross-Site Scripting (XSS)

---

# Challenges Faced

Initially, understanding the difference between Managed Rules and Custom Rules was slightly confusing. After exploring both concepts, it became clear when each should be used.

---

# Cleanup

No billable resources were created during this learning session, so no cleanup was required.

---

# Key Takeaway

AWS WAF provides an additional layer of security for web applications by inspecting incoming requests and blocking malicious traffic before it reaches the application. It is an important service for building secure cloud architectures.

---

# LinkedIn Post

(Add your LinkedIn post URL here)
