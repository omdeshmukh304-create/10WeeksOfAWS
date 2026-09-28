# AWS Day 15 --- Route 53, CloudFront, ACM & Edge Security

## Overview

Day 15 was a hands-on AWS practical focused on combining DNS, CDN,
HTTPS, private S3 content, traffic routing, health checks, failover, and
edge security.

### AWS Services Covered

-   Amazon EC2
-   Amazon S3
-   Amazon CloudFront
-   AWS Certificate Manager (ACM)
-   Amazon Route 53
-   AWS WAF

------------------------------------------------------------------------

## 1. ACM --- Public Certificate and DNS Validation

### Objective

Request a public SSL/TLS certificate for the CloudFront custom domain
and validate ownership through DNS.

### What I Performed

-   Selected **US East (N. Virginia) --- `us-east-1`**
-   Requested a public ACM certificate
-   Used **DNS validation**
-   Used **RSA 2048**
-   Added the ACM validation CNAME at the authoritative DNS provider
-   Waited until the certificate became **Issued**
-   Kept the ACM validation CNAME for certificate renewal

### Why?

CloudFront requires the viewer certificate in `us-east-1` when using a
custom HTTPS hostname.

------------------------------------------------------------------------

## 2. Regional EC2 Endpoints

I created two temporary HTTP endpoints for Route 53 routing and
health-check testing.

### Primary --- Mumbai

-   Region: `ap-south-1`
-   Nginx web server
-   Page: **Primary - Mumbai**
-   HTTP port: `80`

### Secondary --- N. Virginia

-   Region: `us-east-1`
-   Nginx web server
-   Page: **Secondary - N. Virginia**
-   HTTP port: `80`

### Why?

Two regional endpoints make it possible to demonstrate:

-   health checks
-   weighted routing
-   active-passive failover
-   recovery/failback

------------------------------------------------------------------------

## 3. Private S3 Origin

I created a private S3 bucket in Mumbai.

### Configuration

-   Block Public Access enabled
-   Bucket owner enforced
-   Versioning enabled
-   Default encryption enabled
-   S3 static website hosting was not enabled

The bucket contained:

-   `index.html`
-   `private/learner-proof.txt`

### Verification

Direct access to the private S3 content was expected to fail with
`403 AccessDenied`.

### Why?

The objective was to keep S3 private and allow CloudFront to access the
origin securely.

------------------------------------------------------------------------

## 4. CloudFront + Origin Access Control

I created a CloudFront distribution and connected it to the private S3
bucket.

### Configuration

-   S3 REST endpoint as origin
-   Origin Access Control (OAC)
-   HTTP redirected to HTTPS
-   `GET` and `HEAD` methods
-   Managed `CachingOptimized` cache policy
-   Compression enabled
-   Default root object: `index.html`

### Verification

The CloudFront URL successfully served the S3 content while direct S3
access remained private.

### Why OAC?

OAC allows CloudFront to access a private S3 origin without making the
bucket public.

------------------------------------------------------------------------

## 5. CloudFront Cache and Invalidation

I tested CloudFront caching using repeated requests.

I then:

1.  Updated the S3 page from Version 1 to Version 2.
2.  Observed that the previous version could remain cached.
3.  Created a CloudFront invalidation for: `/index.html`
4.  Waited for the invalidation to complete.
5.  Verified Version 2.

### Key Learning

CloudFront can continue serving a cached object until its cache behavior
changes or an invalidation is performed.

------------------------------------------------------------------------

## 6. Signed URL --- Private CloudFront Path

I created an RSA key pair in CloudShell for CloudFront URL signing.

### CloudFront Configuration

-   Created a CloudFront public key
-   Created a key group
-   Added a `private/*` behavior
-   Enabled **Restrict viewer access**
-   Trusted the key group

### Tests

#### Without Signature

The private object returned:

`403 / MissingKey`

#### With Signed URL

A short-lived signed URL successfully returned:

`200`

#### After Expiry

The same signed URL returned:

`403`

### Security Note

The private signing key was not published and was removed from
CloudShell after testing.

### Why?

Signed URLs allow temporary access to a protected CloudFront object
without making the object publicly accessible.

------------------------------------------------------------------------

## 7. Custom Domain + HTTPS

I configured the custom CloudFront hostname:

`cdn.omdevops.in`

### Configuration

-   Added the alternate domain to CloudFront
-   Attached the issued ACM certificate from `us-east-1`
-   Used the recommended TLS 1.2 security policy
-   Added the DNS CNAME pointing the custom hostname to CloudFront

### Verification

The custom HTTPS hostname successfully reached CloudFront.

------------------------------------------------------------------------

## 8. Route 53 --- Delegated Lab Hosted Zone

I created a public hosted zone for:

`lab.omdevops.in`

The four Route 53 name servers were added at the parent DNS provider as
`NS` records for the `lab` subdomain.

### Verification

The delegated zone was verified using DNS queries.

### Why?

This allowed Route 53 to become authoritative for the lab subdomain
without replacing the root domain's nameservers.

------------------------------------------------------------------------

## 9. Route 53 Simple Records

I created simple A records for the two regional endpoints:

-   `primary.lab.omdevops.in`
-   `secondary.lab.omdevops.in`

Each record pointed to its corresponding EC2 public IPv4 address.

------------------------------------------------------------------------

## 10. Route 53 Health Checks

I created health checks for both regional endpoints.

### Primary Health Check

-   Endpoint: Mumbai EC2
-   Protocol: HTTP
-   Port: `80`
-   Path: `/`
-   Interval: Standard `30 seconds`
-   Failure threshold: `3`

### Secondary Health Check

The same configuration was used for the N. Virginia endpoint.

Both endpoints were verified as healthy at baseline.

------------------------------------------------------------------------

## 11. Weighted Routing

I created two weighted A records for:

`weighted.lab.omdevops.in`

### First Test

-   Mumbai: **80**
-   N. Virginia: **20**

I queried the Route 53 authoritative server multiple times to observe
the distribution.

### Second Test

The weights were changed to:

-   Mumbai: **50**
-   N. Virginia: **50**

The authoritative queries were repeated and compared.

### Key Learning

Route 53 weights influence DNS-answer proportions, but they do not
guarantee an exact request ratio because DNS caching affects clients.

------------------------------------------------------------------------

## 12. Failover Routing

I created active-passive failover records for:

`app.lab.omdevops.in`

### Configuration

-   Mumbai → Primary
-   N. Virginia → Secondary
-   Both associated with their health checks

### Baseline

The healthy primary endpoint returned the Mumbai response.

------------------------------------------------------------------------

## 13. Failure Simulation

To test real failover, I stopped only Nginx on the Mumbai EC2 instance.

The instance itself remained running and its public IP stayed unchanged.

### Failure Detection

The Mumbai health check eventually changed to:

**Unhealthy**

### Failover Result

Route 53 switched the authoritative DNS answer to the N. Virginia
endpoint.

The hostname then served:

**Secondary - N. Virginia**

------------------------------------------------------------------------

## 14. Recovery and Failback

I restarted Nginx on the Mumbai instance.

After the health check returned to:

**Healthy**

the Route 53 failover answer returned to the Mumbai primary endpoint.

### Key Learning

This demonstrated both:

-   **Failover**
-   **Failback**

It also showed why authoritative DNS queries are useful when verifying
the current Route 53 routing decision.

------------------------------------------------------------------------

## 15. AWS WAF --- Count and Block Testing

I configured an AWS WAF IP set using my current public IPv4 address as a
`/32`.

### WAF Configuration

-   Scope: **CloudFront (Global)**
-   IP version: IPv4
-   Rule: `Block-Learner-IP`

### Count Test

The rule was initially configured with:

**Action = Count**

The public CloudFront root page continued to work.

WAF traffic/metrics were checked to confirm that the rule matched the
request.

### Block Test

The same rule was then changed to:

**Action = Block**

After propagation, requesting the public root page returned:

**403**

This confirmed that the WAF rule was actively blocking the matching
request.

### Restoration

The rule was returned to **Count**, normal access was verified, and the
temporary IP set was deleted after it was no longer referenced.

### Why?

This demonstrated the difference between:

-   **Count** --- observe/match traffic without blocking it
-   **Block** --- terminate matching requests

------------------------------------------------------------------------

## 16. Final Architecture

``` text
                         Users
                           |
                           v
                    cdn.omdevops.in
                           |
                           v
                    Amazon CloudFront
                    /              \
                   /                \
              AWS WAF              ACM
                 |                  |
                 |              HTTPS/TLS
                 |
                 v
             Private S3
             Origin + OAC


        Route 53 — lab.omdevops.in
                   |
          +--------+--------+
          |                 |
       Mumbai          N. Virginia
       EC2/Nginx        EC2/Nginx
          |                 |
      Health Check      Health Check
          \                 /
           \               /
             Failover
             /     \
        Primary   Secondary
```

------------------------------------------------------------------------

## 17. Key Takeaways

-   ACM DNS validation proves control of the custom domain.
-   CloudFront provides edge caching and HTTPS delivery.
-   S3 can remain private while CloudFront accesses it through OAC.
-   Signed URLs provide temporary access to protected CloudFront
    objects.
-   Route 53 can use health checks with routing policies.
-   Weighted routing distributes DNS answers according to configured
    weights.
-   Failover routing can move traffic to a secondary endpoint when the
    primary becomes unhealthy.
-   Recovery of the primary endpoint can restore the failover
    configuration.
-   AWS WAF can inspect CloudFront requests and use Count or Block
    actions.
-   Testing real failure scenarios provides a better understanding than
    only creating resources.

------------------------------------------------------------------------

## 18. Evidence Screenshots

The following screenshot is my Day 15 evidence overview showing the
captured AWS console/terminal screenshots from the practical.

![Day 15 Screenshot Overview](./day15-screenshot-overview.png)

The screenshot overview includes evidence for:

-   ACM certificate and DNS validation
-   S3 versioning and encryption
-   Direct S3 access denied
-   CloudFront configuration and headers
-   Unsigned private path / MissingKey
-   Custom domain and ACM configuration
-   Route 53 health checks
-   Weighted routing 80/20
-   Weighted routing 50/50
-   Failover baseline
-   Health-check failure
-   Failover to secondary
-   Primary recovery/failback

------------------------------------------------------------------------

## 19. Day 15 Validation Checklist

-   [x] ACM certificate requested and validated in `us-east-1`
-   [x] ACM certificate reached `Issued`
-   [x] Direct S3 access remained private
-   [x] CloudFront OAC access worked
-   [x] Cache behavior and invalidation tested
-   [x] Unsigned private path returned `403`
-   [x] Short-lived signed URL returned `200`
-   [x] Signed URL expired and returned `403`
-   [x] Custom HTTPS hostname configured
-   [x] Route 53 health checks verified
-   [x] Weighted routing tested with 80/20
-   [x] Weighted routing tested with 50/50
-   [x] Primary failure triggered Route 53 failover
-   [x] Primary recovery produced failback
-   [x] WAF Count action tested
-   [x] WAF Block action tested
-   [x] Normal access restored after WAF test

------------------------------------------------------------------------

## 20. Important Security Notes

-   The CloudFront private signing key was never published.
-   The public IP used for the WAF test should not be exposed in
    screenshots.
-   S3 Block Public Access remained enabled.
-   Shield Advanced and Global Accelerator were not provisioned for this
    lab.
-   Temporary lab resources should be cleaned up after completing the
    practical.

------------------------------------------------------------------------

# Day 15 Completed

**Route 53 + CloudFront + ACM + S3 + EC2 + AWS WAF**

Hands-on learning through configuration, verification, failure
simulation, security testing, and recovery.
