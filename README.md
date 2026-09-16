# 🔐 StartupCo AWS Identity & Security Hardening

**Status:** In progress — Identity & Access phase complete; Security Monitoring phase planned next

**Environment status:** Complete

**Focus:** AWS • IAM Identity Center • Terraform • Least Privilege • Identity & Access Management • Cloud Security

A hands-on cloud security portfolio project simulating an identity and security-hardening engagement for a fictional startup. StartupCo had been relying on shared AWS root credentials across all 10 employees; this project rebuilds workforce access around individual identities, group-based least privilege, and Terraform-managed security controls.

Additional diagrams (administrative access flow, planned security-monitoring flow, planned detection-and-response flow) live in [`docs/architecture.md`](docs/architecture.md).

---

## 🏢 The Business Problem

StartupCo launched a fitness-tracking application and has been operating in AWS for about three months. Because the original environment was stood up quickly, all 10 employees were sharing AWS root credentials — passed around in team chat — for routine day-to-day work. That meant no individual accountability, no least privilege, no audit trail tied to a person, and no MFA.

| Team | Users | Required Access |
|---|---|---|
| Developers | 4 | EC2 management, S3 application-file access, CloudWatch Logs viewing |
| Operations | 2 | Full EC2 and CloudWatch access, Systems Manager access, RDS management |
| Finance | 1 | Cost Explorer, AWS Budgets, read-only resource visibility |
| Analysts | 3 | Read-only S3 access, read-only database/data access |

---

## 🏗️ Architecture

```
AWS IAM Identity Center
        |
        +-- Developers  (4 users) → DeveloperPermission
        +-- Operations  (2 users) → OperationPermission
        +-- Finance     (1 user)  → FinancePermission
        +-- Analysts    (3 users) → AnalystPermission
                |
                v
     Permission sets assigned to the AWS workload account
```

---

## 🧠 Key Decisions & Why

### Identity Architecture
- **IAM Identity Center instead of 10 traditional IAM users.** Eliminates long-lived console credentials entirely and centralizes authentication and MFA at the identity-store level instead of per-user.
- **Groups + permission sets instead of per-user policies.** Ten individual policies would drift out of sync over time; a group-membership change is a one-line Terraform diff instead of a new policy to write and review.

### Least-Privilege Design, by group
- **Developers — tag-scoped EC2, not account-wide.** Start/stop/reboot is restricted to instances tagged `Role = app-server`, so a developer credential can't reach infrastructure outside the app tier even where EC2 access is otherwise broad.
- **Operations — full access is the correct call here.** Operations owns EC2/CloudWatch/RDS infrastructure by job function, so AWS-managed full-access policies match the actual business requirement instead of being over-provisioned.
- **Finance — visibility without control.** Cost Explorer/Budgets plus read-only `Describe`/`List`/`Get` verbs only; validated that EC2 start, S3 upload, and Session Manager are all explicitly denied. Financial visibility and infrastructure administration are different jobs and shouldn't share a credential.
- **Analysts — read-only, and a real IAM boundary.** S3 read access is straightforward; RDS is the interesting case. `rds:Describe*` at the IAM level is not the same thing as a SQL `SELECT` at the database level — IAM controls whether you can reach the database resource at all, not what you can query once connected. That boundary had to be documented explicitly, not assumed.

### EC2 Administration
- **Systems Manager Session Manager, no SSH.** No key pair, no port 22, no inbound security-group rule for management at all. Operations gets a real interactive shell through Identity Center → Systems Manager → Session Manager instead.

### Security Monitoring (planned)
- **CloudTrail as the audit layer, GuardDuty as the detective layer, kept deliberately separate.** CloudTrail answers "who did what, when"; GuardDuty answers "is this activity suspicious." Config, Security Hub, EventBridge, and SNS then chain those into a single detect → alert → investigate → remediate flow, tested against one controlled, non-destructive misconfiguration.

---

## 🚀 What I'd Do Differently at Production Scale

- **AWS Organizations + SCPs**, with separate accounts per environment or per function — intentionally out of scope here to keep the project focused on identity and security fundamentals rather than multi-account governance.
- **Automated Config remediation** (e.g., Lambda-backed auto-remediation) instead of a human investigating every finding manually.
- **A delegated Security Hub admin account**, rather than findings living in the same account as the workload.
- **CI/CD-driven permission-set changes** with peer review, instead of applying Terraform directly — access changes are exactly the kind of thing that should require a second set of eyes.
- **Macie** for data classification, if StartupCo's S3 buckets ever held real PII/PHI-type fitness data at scale — deliberately excluded here since the test bucket only holds a sample object.
- **A documented break-glass root procedure** with automatic alerting on any root login, since root should be removed from routine use but still needs a defined emergency path.