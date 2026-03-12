# High Availability and Secure Chaos-Tested Production Infrastructure with Monitoring and Logging

##

## The overview of the project:  
I accepted a job from a client, who was requesting AWS cloud configuration work which needed to be handled in a secure and professional manner. 

##

## **The high level job description request was:**
"I’m ready to launch a production-grade web application on AWS and need the underlying infrastructure designed and built with security and high availability at its core. The workload will run on EC2, and general-purpose instances are fine; the focus is on a rock-solid architecture, not exotic hardware profiles.

Here’s what I have in mind: a VPC with public and private subnets spread across at least two Availability Zones, an Application Load Balancer in front, Auto Scaling groups to keep capacity healthy, and tight security groups plus IAM roles that follow least-privilege rules. Logging to S3, monitoring and alerts through CloudWatch, and encrypted traffic everywhere (ACM certificates, HTTPS, TLS-enabled internal hops) are all must-haves. Wherever possible, I’d like the stack expressed as infrastructure-as-code—Terraform or CloudFormation—so I can version-control and reproduce everything.

**Deliverables**
Architecture diagram (high-level and subnet-level)
IaC templates or modules with clear variables and README
Step-by-step deployment guide and rollback instructions
Brief security checklist showing how OWASP/AWS best practices are met
Final validation session in my account to confirm multi-AZ failover and basic load test success"

##

🛡️ ## **Security & Resilience Architecture**
This project implements a Defense-in-Depth strategy, ensuring that the infrastructure is not only highly available but also hardened against modern attack vectors.

1. Zero-Trust Network Design
Isolated Database Tier: Database instances are placed in dedicated subnets with no Route Table entry to the Internet Gateway, preventing "phone-home" malware communication.

Elimination of Port 22: By leveraging AWS Systems Manager (SSM) and Interface VPC Endpoints, the infrastructure allows for full administration without the need for SSH keys or public-facing Bastion hosts.

Security Group Chaining: Implements a strict "Kill Chain" where the Database only accepts traffic from the App Tier, and the App Tier only accepts traffic from the ALB, preventing lateral movement.

2. Active Threat Mitigation
Intelligent WAF Filtering: An AWS WAF is deployed in front of the Application Load Balancer to inspect Layer 7 traffic, automatically rate-limiting IPs and blocking SQL Injection (SQLi) and Cross-Site Scripting (XSS) attempts.

GuardDuty AI Monitoring: Continuous monitoring of VPC Flow Logs and CloudTrail events via Amazon GuardDuty to detect anomalous behavior, such as unauthorized API calls or compromised instances.

Encryption in Transit: Implements End-to-End TLS (HTTPS). Traffic is encrypted from the client to the ALB and remains encrypted from the ALB to the EC2 instances on port 8080.

3. Automated Reliability & "Chaos" Validation
Multi-AZ Self-Healing: The infrastructure is distributed across two Availability Zones. In the event of a localized data center failure, the Auto Scaling Group (ASG) automatically redistributes capacity to maintain 100% uptime.

Targeted Stress Testing: Validated the scaling policy using Grafana k6 to simulate high-computational load (SHA-256 hashing) and concurrent traffic spikes, confirming the system's ability to scale from 2 to 6 instances dynamically.

Observability Dashboard: A custom CloudWatch Dashboard provides real-time visibility into CPU utilization, Request Count, and Healthy Host counts for rapid incident response.

##

The solution architecture I came up with:
Create dedicated DB Subnets with no internet route, I made it impossible for the database to "call home" to a hacker's server, even if the app layer is compromised.

Elimination of Public Exposure (VPC Endpoints): By using Interface Endpoints for SSM, I completely removed the need for SSH (Port 22) or even a Bastion Host. Instead the client will be managing servers over AWS's private internal fiber.

Defense in Depth (Security Group Chaining): The DB only talks to the App SG, and the App SG only talks to the ALB SG. This creates a "kill chain"—an attacker has to break three distinct layers to reach the data.

Visibility & Accountability: Adding VPC Flow Logs and CloudTrail means the setup will have a "black box recorder" for both network traffic and human API calls. This is a requirement for SOC 2 and HIPAA compliance.

AWS WAF (Web Application Firewall)
A Load Balancer only checks if a packet is coming to the right port. AWS WAF looks inside the packet to see if it contains a SQL injection attack or a Cross-Site Scripting (XSS) script.

Amazon GuardDuty (The AI Watchdog)
I have logs (Flow Logs, CloudTrail), but who is reading them? GuardDuty uses machine learning to analyze those logs 24/7. It will alert if an EC2 instance starts behaving like a crypto-miner or if a login is coming from an unusual country.

S3 Bucket Hardening
Since the code is sending all the sensitive logs to S3, if that bucket is accidentally made public, the client's entire security audit trail is exposed. So hardening the S3 bucket is essential.

Multi-AZ Failover Test (The "Chaos" Test): 
Create tests that verify the auto-scaling and load balancing is working as intended.

Use the k6 tool to send traffic to the ALB's URL.
Show the CloudWatch Dashboard I built for them.
As the traffic climbs, show the CPU utilization rising, and show the Auto Scaling Group adding another server to handle the load.

> [!NOTE]
> This is a blue box for general info.

> [!TIP]
> This is a green box for tips/successes.

> [!IMPORTANT]
> This is a purple box for key security details.

> [!WARNING]
> This is an orange box for warnings.

> [!CAUTION]
> This is a red box for critical "danger" info.
