# Project Challenges Log

A running log of real blockers, gotchas, and lessons learned during the 6-month Cloud/DevOps transition. Every entry here is something that tripped up the build — documented so it never trips you up twice, and so you can speak to it confidently in interviews.

---

## How to read this log

| Field | Meaning |
|---|---|
| **Phase** | Which week/month the issue occurred |
| **Symptom** | What you saw — the error or missing thing |
| **Root cause** | Why it happened |
| **Fix** | Exact steps that resolved it |
| **Lesson** | What this teaches about AWS / the tool |
| **Interview angle** | How to turn this into a talking point |

---

## Challenge 001 — Billing metrics not visible in CloudWatch

**Date:** April 2026  
**Phase:** Week 1 · Phase 0 — Billing alarm setup  
**Severity:** Low (blocker for setup, not for infrastructure)

### Symptom

Navigating to CloudWatch → Alarms → Create alarm → Select metric showed no **Billing** namespace. The option simply did not exist.

### Root cause

AWS billing metrics are **disabled by default** at the account level. Until explicitly enabled, the `AWS/Billing` namespace does not exist in CloudWatch — there is nothing to query even if you look in the right place.

Additionally, billing metrics are a **global service** in AWS and are only published to one region: **us-east-1 (N. Virginia)**. Even if your entire workload runs in `ca-central-1`, you must switch to `us-east-1` to create billing alarms.

### Fix

**Step 1 — Enable billing alerts (do this once per account)**

1. Open the AWS Billing Dashboard — search "Billing" in the console search bar
2. Left sidebar → **Billing preferences**
3. Under "Alert preferences", check: ☑ **Receive CloudWatch billing alerts**
4. Click **Save preferences**

**Step 2 — Wait for metrics to appear**

After enabling, AWS takes 5–15 minutes (sometimes up to 1 hour) to populate the `AWS/Billing` namespace. This is a known AWS behaviour — there is no way to force it faster.

**Step 3 — Switch region to us-east-1**

Billing metrics only exist in `us-east-1`. Switch your console region to **US East (N. Virginia)** before creating the alarm. Switch back to `ca-central-1` immediately after.

**Step 4 — Create the alarm**

CloudWatch → Alarms → Create alarm → Select metric → **Billing** → Total Estimated Charge → USD → set threshold → create.

**Step 5 — Switch region back**

Top-right region selector → **Canada (Central) ca-central-1** — all infrastructure resources live here.

### Lesson

> AWS has a category of **global services** that only exist in `us-east-1` regardless of where your workload runs. Billing, IAM, Route 53, CloudFront, and AWS Organizations all fall into this category. When a console feature seems missing, always check: (1) is the feature enabled at the account level? (2) is it a global service that requires a specific region?

### Other global services to remember

| Service | Why global | Where to manage |
|---|---|---|
| AWS IAM | Identity applies across all regions | us-east-1 / any region |
| AWS Billing | Financial data is account-wide | us-east-1 only |
| Route 53 | DNS is global | us-east-1 |
| CloudFront | CDN edge is global | us-east-1 |
| AWS Organizations | Account management | us-east-1 |

### Interview angle

*"During my AWS build I ran into an issue where CloudWatch billing metrics weren't appearing. I traced it to two root causes: billing alerts aren't enabled by default at the account level, and billing is a global service that only publishes metrics to us-east-1. This taught me to always check whether a missing feature requires account-level activation and whether it's a global service requiring a specific region — a pattern that comes up repeatedly in AWS."*

---

## Challenge 002 — New AWS account security hardening

**Date:** April 2026
**Phase:** Week 1 · Pre-build · Account setup
**Severity:** High (security baseline — must be done before any infrastructure)

### What needs to be done on every new AWS account

1. Enable MFA on root immediately
2. Delete root access keys
3. Enable IAM access to billing (off by default)
4. Enable CloudWatch billing alerts (off by default)
5. Enable Cost Explorer (off by default)
6. Create billing alarm in us-east-1 (billing is global, ca-central-1 won't show it)
7. Create admin IAM user with AdministratorAccess + Billing policies + MFA
8. Create dev IAM user with scoped permissions + CLI access keys only
9. Never use root for daily work again

### Lesson
AWS ships new accounts in a deliberately minimal state.
Security features, billing visibility, and cost alerts are all
opt-in. Hardening an account takes 30 minutes and prevents
the most common account compromise and runaway cost scenarios.

### Interview angle
"When I set up my AWS account I immediately secured the root
user with MFA, deleted root access keys, created separate
admin and dev IAM users following least-privilege principles,
and enabled billing visibility and alerts. I treat account
hardening as infrastructure — it is the foundation everything
else runs on."

---

## Challenge 003 — AWS account default security gaps

**Date:** April 2026
**Phase:** Week 1 · Pre-build · Account setup
**Severity:** High (security baseline — must be done before any infrastructure)

### Services NOT enabled by default on a new account:
CloudTrail, GuardDuty, Config, Security Hub, billing alerts,
Cost Explorer. Each must be explicitly activated. CloudTrail
and GuardDuty should be enabled immediately on any new account.
Config and Security Hub are best deferred until you have
mature infrastructure to evaluate.

---

## Challenge 004 — NAT Gateway creation interface updated

**Date:** April 2026
**Phase:** Week 1 · Phase 4 — NAT Gateway creation
**Severity:** Low (UI change, not a blocker once understood)

### Symptom
The NAT Gateway creation screen showed two new fields not
covered in the original walkthrough: Availability mode
(Regional vs Zonal) and Method of EIP allocation
(Automatic vs Manual).

### What changed
AWS added Regional NAT Gateway mode — a new option where
AWS automatically manages EIP allocation and AZ coverage
across all AZs in the region. This simplifies management
but removes explicit per-AZ control.

### Decision made
Selected Zonal + Manual for both NAT Gateways.

Reason: explicit per-AZ NAT Gateways are an AWS
Well-Architected reliability best practice. Each private
subnet routes outbound traffic through the NAT Gateway
in its own AZ — if AZ-A fails, AZ-B traffic is unaffected.
Regional mode obscures this architecture and makes it
harder to reason about failure domains.

### Lesson
AWS console interfaces change frequently. When a field
appears that is not in your documentation, read the
description carefully and ask: does the new option trade
control for convenience? For learning environments and
production architectures where you need to understand
failure domains, explicit control (Zonal) is always
preferable to managed automation (Regional).

### Interview angle
"AWS introduced Regional NAT Gateways which automatically
manage AZ coverage. I chose Zonal NAT Gateways deliberately
because the Well-Architected reliability pillar requires
understanding your failure domains — I needed explicit
per-AZ routing so that an AZ failure doesn't take down
outbound connectivity for the other AZ."

---

---

*This log is updated in real time as challenges are encountered. Each entry is a documented learning, not a failure.*