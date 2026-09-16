# StartupCo — Supporting Architecture Diagrams

These support the main architecture overview in the [README](../README.md) with more detail on administration and the planned security-monitoring flow than the top-level README needs.

---

## Administrative Access Flow

```
Cloud Administrator (Operations)
        ↓
IAM Identity Center
        ↓
AWS Systems Manager → Session Manager
        ↓
Private EC2
```

No SSH key pair, no port 22, no inbound administrative security-group rule.

---

## Planned Security Monitoring Flow

```
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

CloudTrail provides the audit trail needed to determine which identity performed the relevant AWS API operations once a finding is under investigation.

---

## Planned Detection & Response Test Flow

```
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

The controlled test is performed only against non-sensitive lab resources.