# StartupCo AWS Identity & Security Hardening

## Overview

This project simulates an AWS identity and cloud-security hardening engagement for a fictional technology startup named **StartupCo**.

StartupCo recently launched a fitness-tracking application and has been operating in AWS for approximately three months. Because the original environment was deployed quickly, several significant identity and access-management weaknesses were introduced.

The most serious issue was that the company's employees were effectively relying on shared AWS root credentials rather than individual workforce identities and role-based authorization.

The environment is being redesigned around:

- AWS IAM Identity Center
- individual workforce identities
- group-based authorization
- least-privilege permission sets
- MFA
- secure EC2 administration through AWS Systems Manager
- Terraform-managed security controls
- AWS auditing, detection, compliance, and alerting services

This project is intentionally focused on **identity and cloud security engineering** rather than application development or complex network architecture.

---

## Business Scenario

StartupCo has 10 employees divided across four functional teams.

| Team | Users | Required Access |
|---|---:|---|
| Developers | 4 | EC2 management, S3 application-file access, CloudWatch Logs viewing |
| Operations | 2 | Full EC2 and CloudWatch access, Systems Manager access, RDS management |
| Finance | 1 | Cost Explorer, AWS Budgets, read-only resource visibility |
| Analysts | 3 | Read-only S3 access and read-only database/data access |

### Original Security Problems

The original AWS environment had several major weaknesses:

- Employees were sharing AWS root credentials
- Root credentials were used for routine AWS access
- No individual workforce identities
- No separation of duties
- No least-privilege access model
- No team-specific authorization
- Credentials had been shared through team communication channels
- Limited individual accountability
- Limited audit visibility
- Limited security monitoring and detection

---

## Security Objectives

The hardened environment is being designed so that:

- Every employee has an individual AWS workforce identity
- AWS IAM Identity Center provides centralized authentication
- Users are placed into groups based on job function
- Permission sets enforce role-based least privilege
- Root credentials are removed from routine administrative use
- MFA protects workforce authentication
- EC2 administration does not require SSH
- AWS API activity can be audited
- Configuration changes can be evaluated for compliance
- Suspicious AWS activity can be detected
- Security findings can generate notifications
- Security controls are defined through Terraform

---

## Architecture Strategy

Instead of creating traditional IAM users with long-lived AWS credentials, workforce access is implemented using **AWS IAM Identity Center**.

```text
AWS IAM Identity Center
        |
        +-- Developers
        |      4 users
        |
        +-- Operations
        |      2 users
        |
        +-- Finance
        |      1 user
        |
        +-- Analysts
               3 users
```

Each group receives a dedicated Identity Center permission set based on its business responsibilities.

```text
Developers
    ↓
DeveloperPermission

Operations
    ↓
OperationPermission

Finance
    ↓
FinancePermission

Analysts
    ↓
AnalystPermission
```

The permission sets are then assigned to the AWS workload account.

---

# Least-Privilege Access Model

## Developers

Developers are permitted to:

- View EC2 instances
- Start approved application EC2 instances
- Stop approved application EC2 instances
- Reboot approved application EC2 instances
- List the StartupCo application-data S3 bucket
- Read application objects
- Upload application objects
- Delete approved application objects
- View CloudWatch Logs

EC2 management is restricted using resource tags.

Approved application instances contain:

```text
Role = app-server
```

Developer EC2 management actions use that resource tag as an authorization condition.

Developers are not granted:

- Billing administration
- Systems Manager administrative access
- IAM administration
- RDS administration
- General AWS administrative privileges

---

## Operations

Operations personnel are permitted to:

- Manage EC2
- Manage CloudWatch
- Manage CloudWatch Logs
- Use AWS Systems Manager
- Start Session Manager sessions
- Run Systems Manager commands
- Manage RDS resources

Administrative access to EC2 uses:

```text
IAM Identity Center
        ↓
OperationPermission
        ↓
AWS Systems Manager
        ↓
Session Manager
        ↓
EC2
```

The EC2 test instance uses:

- no SSH key pair
- no port 22 access
- no inbound administrative security-group rule

Systems Manager Session Manager provides administrative access instead.

---

## Finance

Finance is permitted to:

- View AWS Cost Explorer
- View AWS Budgets
- Modify AWS Budgets
- View EC2 resource metadata
- View S3 bucket metadata
- View RDS resource metadata

Finance is prevented from performing infrastructure administration.

Validated restrictions include:

- EC2 start denied
- EC2 stop denied
- S3 object upload denied
- Systems Manager Session Manager denied

This creates separation between:

```text
Financial visibility
        ≠
Infrastructure administration
```

---

## Analysts

Analysts are designed to receive:

- read-only access to the StartupCo application-data bucket
- S3 bucket listing
- S3 object retrieval
- read-only RDS resource visibility

Analysts should not receive:

- S3 upload
- S3 delete
- EC2 management
- Systems Manager access
- billing access
- infrastructure administration

Database control-plane permissions and database data permissions are intentionally treated separately.

```text
rds:Describe*
        ≠
SQL SELECT permissions
```

AWS IAM permissions can control access to RDS resources, but true read-only access to database records requires authorization inside the database itself.

---

# Minimal Test Infrastructure

The project intentionally uses a small AWS workload.

The purpose of the infrastructure is to provide real resources against which security controls and least-privilege permissions can be tested.

Current test infrastructure includes:

- 1 Amazon Linux EC2 instance
- 1 S3 application-data bucket
- 1 sample S3 object
- 1 CloudWatch Log Group
- 1 EC2 IAM instance role
- Systems Manager integration
- default VPC networking

The infrastructure is deliberately minimal because this project is focused on AWS security rather than application architecture.

---

# Infrastructure as Code

Terraform is used to manage the environment.

Terraform currently manages:

- IAM Identity Center groups
- IAM Identity Center users
- group memberships
- permission sets
- permission-set inline policies
- AWS account assignments
- EC2 test infrastructure
- EC2 IAM instance profile
- S3 test resources
- S3 public-access controls
- S3 encryption configuration
- CloudWatch Log Group
- Systems Manager permissions

Using Terraform provides a repeatable desired-state security configuration.

---

# Identity Center Implementation

The environment contains:

```text
10 workforce identities
4 Identity Center groups
4 permission sets
10 group memberships
4 AWS account assignments
```

The workforce model is:

```text
Developers
├── Alice
├── Bob
├── Charlie
└── Dave

Operations
├── Eve
└── Frank

Finance
└── Grace

Analysts
├── Heidi
├── Ivan
└── Judy
```

Only representative identities need to be used for interactive access testing because permissions are inherited through group membership.

---

# Least-Privilege Validation

Permission validation includes both:

```text
Allowed action testing
+
Denied action testing
```

This verifies that users can perform their required job functions while being prevented from performing unauthorized operations.

---

## Developer Validation

A representative Developer identity was used for testing.

Validated allowed actions:

- view EC2
- start approved application EC2 instance
- stop approved application EC2 instance
- reboot approved application EC2 instance
- list StartupCo S3 bucket
- retrieve S3 objects
- upload S3 objects
- view CloudWatch Logs

Validated denied actions:

- Billing / Cost Explorer access
- Systems Manager administrative access
- broader administrative AWS access

---

## Operations Validation

A representative Operations identity was used for testing.

Validated allowed actions:

- EC2 management
- CloudWatch access
- CloudWatch Logs access
- AWS Systems Manager access
- successful Session Manager shell into EC2
- RDS control-plane access

The successful Session Manager test demonstrated EC2 administrative access without SSH.

Validated denied access:

- Finance-specific billing access

---

## Finance Validation

A representative Finance identity was used for testing.

Validated allowed actions:

- AWS Cost Explorer
- AWS Budgets
- budget modification
- EC2 read-only visibility
- S3 bucket/resource visibility
- RDS resource visibility

Validated denied actions:

- EC2 start
- infrastructure modification
- S3 application-data upload
- Systems Manager Session Manager

This demonstrates separation of duties between cost management and infrastructure administration.

---

## Analyst Validation

Analyst validation is the next access-control test.

Planned tests include:

```text
S3 list                     → ALLOW
S3 GetObject                → ALLOW
S3 PutObject                → DENY
S3 DeleteObject             → DENY

EC2 management              → DENY
Systems Manager             → DENY
Billing / Cost Explorer     → DENY
```

---

# Security Control Architecture

Identity hardening is the first phase of the project.

Additional security controls will provide auditing, configuration compliance, threat detection, finding aggregation, and security alerting.

| Security Requirement | AWS Service |
|---|---|
| Workforce authentication | IAM Identity Center |
| Role-based authorization | Identity Center Groups + Permission Sets |
| Strong authentication | MFA |
| API activity auditing | AWS CloudTrail |
| Configuration compliance | AWS Config |
| Threat detection | Amazon GuardDuty |
| Security finding aggregation | AWS Security Hub |
| Security event routing | Amazon EventBridge |
| Security notifications | Amazon SNS |
| Encryption/key management | AWS KMS |
| Secrets management | AWS Secrets Manager |
| Secure EC2 administration | Systems Manager Session Manager |
| Infrastructure as Code | Terraform |

---

# Planned Security Monitoring Architecture

The planned security flow is:

```text
AWS Resources
      |
      +-------------------+
      |                   |
      v                   v
 AWS Config           GuardDuty
      |                   |
      +---------+---------+
                |
                v
          Security Hub
                |
                v
          EventBridge
                |
                v
               SNS
                |
                v
      Security Notification
```

CloudTrail will provide the audit trail needed to determine which identity performed relevant AWS API operations.

---

# Planned Detection and Response Test

The project will include a controlled security misconfiguration.

The purpose is to demonstrate an end-to-end cloud-security workflow rather than simply enabling AWS security services.

```text
Secure Terraform Baseline
        ↓
Controlled Misconfiguration
        ↓
AWS Config Detects Noncompliance
        ↓
Security Event / Finding
        ↓
EventBridge
        ↓
SNS Notification
        ↓
Security Investigation
        ↓
CloudTrail Attribution
        ↓
Terraform Remediation
        ↓
Compliance Revalidated
```

The controlled test will be performed only against non-sensitive lab resources.

---

# Planned Security Services

The next implementation phase includes:

- AWS CloudTrail
- AWS Config
- Amazon GuardDuty
- AWS Security Hub
- Amazon EventBridge
- Amazon SNS
- AWS KMS
- AWS Secrets Manager

The project intentionally avoids adding security services that do not contribute directly to the business scenario.

---

# Evidence

Screenshots are being captured during security validation.

Evidence includes:

- successful authorized operations
- denied unauthorized operations
- Identity Center role context
- Session Manager access
- EC2 permission boundaries
- S3 permission boundaries
- Billing separation of duties

Screenshots will be published only after AWS account identifiers and other sensitive information have been redacted.

Planned structure:

```text
docs/
└── screenshots/
    ├── developer/
    ├── operations/
    ├── finance/
    └── analyst/
```

---

# Project Status

## Identity & Access

- [x] IAM Identity Center configured
- [x] 10 workforce identities created
- [x] Developers group created
- [x] Operations group created
- [x] Finance group created
- [x] Analysts group created
- [x] Group memberships configured
- [x] Developer permission set
- [x] Operations permission set
- [x] Finance permission set
- [x] Analyst permission set
- [x] AWS account assignments
- [x] Developer least-privilege validation
- [x] Operations least-privilege validation
- [x] Finance least-privilege validation
- [ ] Analyst least-privilege validation

## Test Infrastructure

- [x] EC2 test instance
- [x] S3 application-data bucket
- [x] S3 test object
- [x] CloudWatch Log Group
- [x] Systems Manager EC2 role
- [x] Session Manager administrative access
- [x] SSH eliminated from administration

## Security Monitoring

- [ ] CloudTrail
- [ ] AWS Config
- [ ] GuardDuty
- [ ] Security Hub
- [ ] EventBridge security routing
- [ ] SNS security notifications
- [ ] KMS integration
- [ ] Secrets Manager integration

## Detection & Response

- [ ] Controlled security misconfiguration
- [ ] Compliance detection
- [ ] Security notification
- [ ] CloudTrail investigation
- [ ] Terraform remediation
- [ ] Compliance revalidation

---

# Project Goal

The project is designed to demonstrate the ability to answer:

```text
WHO can access AWS?

WHAT resources can they access?

WHAT actions can they perform?

WHY do they require those permissions?

HOW is unnecessary access prevented?

HOW is AWS activity audited?

HOW are insecure configurations detected?

HOW are security events investigated?

HOW are security issues remediated?
```

The final environment represents a small AWS cloud-security hardening engagement using modern workforce identity, least privilege, Infrastructure as Code, secure administration, auditing, detection, and security operations.