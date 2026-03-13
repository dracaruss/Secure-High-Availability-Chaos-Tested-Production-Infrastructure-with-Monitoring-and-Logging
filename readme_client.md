## Project: Secure AWS Web Stack

#Overview: A highly available, WAF-protected ALB + EC2 stack in a custom VPC.

##

# **Security & Resilience Architecture**  
> [!IMPORTANT]
>WAFv2 with Log4j, SQLi, and Common Rule Set protection.
>
>KMS-encrypted S3 logging buckets and SNS topics.
>
>Restricted Default Security Group to prevent lateral movement.
>
>No SSH keys (uses AWS SSM for secure access).

##

## **Zero-Trust Network Design**  
*Isolated Database Tier:*  
>Database instances are placed in dedicated subnets with no Route Table entry to the Internet Gateway, preventing "phone-home" malware communication.

*Elimination of Port 22:*  
>By leveraging AWS Systems Manager (SSM) and Interface VPC Endpoints, the infrastructure allows for full administration without the need for SSH keys or public-facing Bastion hosts.

*Security Group Chaining:*  
>Implements a strict "Kill Chain" where the Database only accepts traffic from the App Tier, and the App Tier only accepts traffic from the ALB, preventing lateral movement.  


## Active Threat Mitigation  
*Intelligent WAF Filtering:*  
>An AWS WAF is deployed in front of the Application Load Balancer to inspect Layer 7 traffic, automatically rate-limiting IPs and blocking SQL Injection (SQLi) and Cross-Site Scripting (XSS) attempts.

*GuardDuty AI Monitoring:*  
>Continuous monitoring of VPC Flow Logs and CloudTrail events via Amazon GuardDuty to detect anomalous behavior, such as unauthorized API calls or compromised instances.

*Encryption in Transit:*  
>Implements End-to-End TLS (HTTPS). Traffic is encrypted from the client to the ALB and remains encrypted from the ALB to the EC2 instances on port 8080.

## Automated Reliability & "Chaos" Validation
*Multi-AZ Self-Healing:*  
>The infrastructure is distributed across two Availability Zones. In the event of a localized data center failure, the Auto Scaling Group (ASG) automatically redistributes capacity to maintain 100% uptime.

*Targeted Stress Testing:*  
>Validated the scaling policy using Grafana k6 to simulate high-computational load (SHA-256 hashing) and concurrent traffic spikes, confirming the system's ability to scale from 2 to 6 instances dynamically.

*Observability Dashboard:*  
>A custom CloudWatch Dashboard provides real-time visibility into CPU utilization, Request Count, and Healthy Host counts for rapid incident response.

##  

*The folder structure is:*  
>/client-project-name  
>├── providers.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Who": AWS & Terraform version settings  
>├── main.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "What": VPC, ALB, and Network resources  
>├── compute.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Logic": EC2 Instances and Auto Scaling  
>├── security.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Guardrails": IAM Roles, WAF, Security Groups  
>├── variables.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Inputs": Configurable settings (Regions, CIDRs)  
>├── outputs.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Results": ALB URL, Instance IDs  
>├── data.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The data  
>├── monitoring.tf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The monitoring resources  
>├── terraform.tfvars&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Values": Actual data for the variables  
>└── README.md&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# The "Manual": How the client deploys it  

##

# **How to Deploy:**
1. Ensure AWS CLI is configured with the profile named in terraform.tfvars.
2. terraform init
3. terraform plan
4. terraform apply

Note on Checkov: All infrastructure has been audited.  
Intentional "Skips" are documented inline within the .tf files for specific cost/demo trade-offs.
