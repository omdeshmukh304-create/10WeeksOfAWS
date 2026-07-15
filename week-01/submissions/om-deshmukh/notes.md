# Week 1 Notes

## Day 1 – Cloud Foundations

The first day was focused on understanding the basic structure of AWS Cloud. I learned that AWS organizes its infrastructure into Regions, Availability Zones (AZs), and Edge Locations.

A **Region** is a geographical location where AWS provides cloud services. Each Region contains multiple **Availability Zones**, which are physically separate data centers connected through high-speed networking. Deploying applications across multiple Availability Zones helps improve high availability because if one Availability Zone fails, another can continue serving the application.

I also learned about **Edge Locations**, which are primarily used by Amazon CloudFront to deliver content closer to users. This reduces latency and improves the overall user experience.

Another important concept I studied was the **AWS Shared Responsibility Model**. AWS is responsible for securing the infrastructure that runs cloud services, including physical data centers, networking equipment, storage devices, and servers. As a customer, I am responsible for securing everything I build in the cloud, such as IAM users, permissions, applications, data, operating system updates, and security configurations.

One of the key lessons from Day 1 was understanding that cloud security is a shared responsibility between AWS and the customer.

---

## Day 2 – IAM Basics

The second day focused on AWS Identity and Access Management (IAM), which is the service used to control who can access AWS resources and what actions they are allowed to perform.

I learned that IAM consists of four major components:

An **IAM User** represents a permanent identity for a person or application.

An **IAM Group** is a collection of users who require the same permissions. Instead of attaching permissions to every individual user, permissions can be attached to a group, making administration easier.

An **IAM Role** provides temporary permissions to trusted users, AWS services, or external identities. Unlike IAM users, roles do not have permanent credentials and are commonly used in automation and cross-service communication.

An **IAM Policy** is a JSON document that defines permissions. Policies specify which actions are allowed or denied on particular AWS resources.

I also learned the **Principle of Least Privilege**, which recommends granting only the permissions required to complete a task. This minimizes security risks and prevents unnecessary access to AWS resources.

---

## Day 3 – Account Security

On the third day, I focused on securing my AWS account.

The first task was enabling **Multi-Factor Authentication (MFA)** for the Root User. Since the Root User has unrestricted access to the AWS account, enabling MFA provides an additional layer of protection by requiring both a password and a verification code during login.

I also created an **AWS Budget** to monitor cloud spending. Although I am currently using the AWS Free Tier, creating a budget helps receive alerts before unexpected charges occur. Monitoring costs from the beginning is considered a good cloud practice.

One important lesson from this lab was never to share sensitive information such as Access Keys, Secret Keys, MFA QR codes, or payment details.

---

## Day 4 – IAM Hands-on

This was the most practical day of the week.

I created multiple IAM Groups with different permission levels, including S3 Read-Only, EC2 Read-Only, and Billing Read-Only groups. Separate IAM users were created and assigned to these groups to understand how permissions work in practice.

After signing in with different IAM users, I tested both allowed and denied operations. For example, the S3 Read-Only user was able to view S3 buckets but was denied permission to create or delete buckets. Similarly, the EC2 Read-Only user could access the EC2 dashboard but could not launch or terminate instances.

I also created my first **Customer Managed Policy**, which granted read-only access to a single S3 bucket. This helped me understand the difference between AWS Managed Policies and Customer Managed Policies. Customer Managed Policies provide more precise control because permissions can be restricted to specific resources instead of granting access to every resource of the same type.

This lab clearly demonstrated how the Principle of Least Privilege works in real AWS environments.

---

## Day 5 – GitHub OIDC Challenge

The optional GitHub OIDC challenge introduced a modern and secure authentication method for GitHub Actions.

Instead of storing AWS Access Keys and Secret Keys inside GitHub Secrets, I configured **OpenID Connect (OIDC)** between GitHub and AWS. I added GitHub as an OIDC Identity Provider, created an IAM Role, configured the Trust Policy, and successfully authenticated GitHub Actions using AWS Security Token Service (STS).

The GitHub Actions workflow successfully assumed the IAM Role and executed AWS CLI commands such as `aws sts get-caller-identity` and `aws s3 ls` using temporary credentials.

This challenge helped me understand how modern CI/CD pipelines securely access AWS without using long-lived credentials.

---

# Overall Learning

Week 1 helped me build a strong foundation in AWS Cloud and Identity Management. Along with understanding the theoretical concepts, I implemented them through hands-on labs, which made it much easier to understand how authentication, authorization, permissions, and cloud security work in AWS.

The most valuable concept I learned this week was the Principle of Least Privilege and how GitHub OIDC improves the security of CI/CD pipelines by replacing long-lived AWS Access Keys with temporary credentials issued by AWS STS.
