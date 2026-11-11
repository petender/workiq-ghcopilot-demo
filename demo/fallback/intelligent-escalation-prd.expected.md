# Intelligent Escalation Pilot - Product Requirements

> **Fallback artifact:** This fictional expected output is for rehearsal and
> live-demo recovery. It is not evidence that WorkIQ completed a live query.

## Document control

| Field | Value |
|---|---|
| Status | Draft |
| Business owner | Maya Chen, VP of Customer Support |
| Engineering owner | Open |
| Last grounded | September 18, 2026 |

## Problem statement

Enterprise support cases are escalated inconsistently, which delays qualified
engineering engagement and creates avoidable escalations. Support agents and
managers need a consistent, explainable recommendation while retaining human
control over the final decision.

## Business outcomes and success measures

- Reduce median time from qualifying risk to engineering escalation by 30%.
- Limit the increase in false escalations to no more than 10% against the
  current baseline.
- Produce a recommendation within two minutes of a qualifying case update.

## Personas

| Persona | Need |
|---|---|
| Support agent | Understand when a case presents elevated escalation risk. |
| Support manager | Review an explainable recommendation and make the final decision. |
| Support operations lead | Control pilot rollout and measure outcomes safely. |
| Compliance reviewer | Verify approval, retention, and data-minimization controls. |

## User journey

1. An eligible pilot case is opened or updated.
2. The service evaluates severity, customer tier, sentiment category, and
   repeat-contact count.
3. At a risk score of 80 or higher, the experience shows an escalation
   recommendation and its contributing signals.
4. A support manager approves, dismisses, or overrides the recommendation and
   records a reason when it is not approved as presented.
5. The system records the decision for audit and pilot reporting.

## Scope

### In scope

- English-language cases for North America enterprise accounts.
- A feature-flagged cohort of 20 support agents plus their managers.
- Explainable recommendations based on the four approved signal categories.
- Human approval and auditable decision capture.

### Out of scope

- Autonomous engineer paging.
- Automatic customer communication or case-severity changes.
- Global or production rollout.
- Replacement of the case-management platform.

## Functional requirements

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-001 | Evaluate eligible pilot cases after a qualifying case update. | Must | [SharePoint brief](https://example.invalid/sharepoint-brief) |
| FR-002 | Recommend escalation when the risk score is 80 or higher. | Must | [Teams decision](https://example.invalid/teams-thread) |
| FR-003 | Show severity, customer tier, sentiment category, and repeat-contact count as contributing signals without exposing internal weights. | Must | [Teams decision](https://example.invalid/teams-thread) |
| FR-004 | Require a support manager to approve, dismiss, or override each recommendation before escalation. | Must | [Teams decision](https://example.invalid/teams-thread) |
| FR-005 | Require a reason when a manager dismisses or overrides a recommendation. | Must | [Compliance email](https://example.invalid/compliance-email) |
| FR-006 | Allow operations to disable new recommendations without a deployment. | Must | [Teams decision](https://example.invalid/teams-thread), [Compliance email](https://example.invalid/compliance-email) |
| FR-007 | Limit initial access to 20 support agents and their managers. | Must | [Teams decision](https://example.invalid/teams-thread) |

## Non-functional and compliance requirements

| ID | Requirement | Source |
|---|---|---|
| NFR-001 | Produce a recommendation within two minutes of a qualifying case update. | [SharePoint brief](https://example.invalid/sharepoint-brief) |
| NFR-002 | Exclude raw customer message text, attachments, and excerpts from model and application telemetry. | [Compliance email](https://example.invalid/compliance-email) |
| NFR-003 | Retain the recommendation, signal categories, final decision, applicable override reason, timestamp, and approving manager identity for 13 months. | [Compliance email](https://example.invalid/compliance-email) |
| NFR-004 | Encrypt audit records in transit and at rest using approved enterprise controls. | [Compliance email](https://example.invalid/compliance-email) |
| NFR-005 | Ensure aggregate pilot reporting does not expose customer message content or directly identify customers. | [Compliance email](https://example.invalid/compliance-email) |

## Acceptance criteria

### AC-001 - Recommend escalation at the approved threshold

- **Given** an eligible pilot case has a calculated risk score of 80
- **When** a qualifying case update is processed
- **Then** an escalation recommendation is shown within two minutes

### AC-002 - Do not recommend below the threshold

- **Given** an eligible pilot case has a calculated risk score below 80
- **When** a qualifying case update is processed
- **Then** no escalation recommendation is shown

### AC-003 - Preserve human approval

- **Given** an escalation recommendation is shown
- **When** no support manager has approved it
- **Then** the system does not submit an escalation or page an engineer

### AC-004 - Explain the recommendation safely

- **Given** an escalation recommendation is shown
- **When** a support manager reviews it
- **Then** the approved contributing signal values are visible
- **And** internal weights and raw customer message text are not visible

### AC-005 - Record an override

- **Given** a support manager dismisses or overrides a recommendation
- **When** the manager submits the decision
- **Then** a reason is required and the complete decision record is retained

### AC-006 - Disable recommendations

- **Given** the pilot feature is enabled
- **When** operations activates the emergency kill switch
- **Then** new recommendations stop without an application deployment

## Telemetry and measurement

- Measure recommendation latency, manager decisions, escalation outcomes, and
  aggregate false-escalation rates.
- Do not collect raw customer message text, attachments, excerpts, or direct
  customer identifiers in pilot telemetry.
- The method for calculating the current false-escalation baseline is open.

## Dependencies and risks

| Item | Type | Mitigation or owner |
|---|---|---|
| Risk-scoring formula is undefined | Dependency | Engineering and Product to propose and review before implementation. |
| Feature-flag platform is undefined | Dependency | Engineering to select an approved platform. |
| Baseline measurement method is undefined | Risk | Support Operations to define before pilot evaluation. |
| Approved encryption controls are unnamed | Dependency | Security to confirm the enterprise standard. |

## Open questions

- OQ-001: What formula and weighting produce the risk score?
- OQ-002: Which approved feature-flag platform will control the pilot?
- OQ-003: How is the current false-escalation baseline calculated?
- OQ-004: Which specific enterprise encryption controls apply to audit records?
- OQ-005: Which case updates trigger reevaluation?

## Superseded decisions

| Topic | Earlier value | Current value | Evidence |
|---|---|---|---|
| Pilot risk threshold | 70 | 80 | [SharePoint brief](https://example.invalid/sharepoint-brief) superseded by the later [Teams decision](https://example.invalid/teams-thread) |

## Source traceability

| Requirement IDs | Source | Evidence summary | Source URL |
|---|---|---|---|
| FR-001, NFR-001 | SharePoint business brief | Pilot scope, signals, outcomes, and two-minute target. | [Open source](https://example.invalid/sharepoint-brief) |
| FR-002, FR-003, FR-004, FR-006, FR-007 | Teams decision thread | Threshold 80 supersedes 70; manager approval, explainability, feature flag, and cohort decisions. | [Open source](https://example.invalid/teams-thread) |
| FR-005, FR-006, NFR-002, NFR-003, NFR-004, NFR-005 | Compliance email | Audit, retention, encryption, kill switch, and data-minimization constraints. | [Open source](https://example.invalid/compliance-email) |
