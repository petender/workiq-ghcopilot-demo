# Intelligent Escalation Pilot - Business Brief

**Project marker:** Project Northstar Escalation  
**Owner:** Maya Chen, VP of Customer Support  
**Status:** Draft for stakeholder review  
**Last updated:** September 8, 2026  
**Target location:** SharePoint, Support Transformation site

## Executive summary

Enterprise customers expect urgent support cases to reach the right engineering
team quickly. Today, escalation depends too heavily on an individual support
agent recognizing risk and knowing whom to contact. Contoso Support will pilot
an Intelligent Escalation capability that identifies high-risk cases and gives
support managers a clear recommendation.

The capability recommends action. It must not autonomously page engineers,
change case severity, or contact customers.

## Business problem

- High-risk cases are escalated inconsistently across shifts.
- Repeated customer contacts and deteriorating sentiment are often noticed too
  late.
- Support managers lack a consistent explanation for why a case should be
  escalated.
- Engineering teams receive some avoidable escalations with insufficient
  context.

## Pilot scope

- North America enterprise support accounts.
- English-language support cases.
- A small cohort of support agents and managers.
- Recommendation shown inside the existing support case experience.
- Signals considered: current severity, customer tier, customer sentiment, and
  the number of contacts about the same issue.

## Initial decision rules

For this draft, recommend escalation when the case risk score is **70 or
higher**. The recommendation must show the signals that contributed to the
score so a support manager can make the final decision.

## Desired user journey

1. A support agent opens or updates an eligible case.
2. The service evaluates the approved risk signals.
3. When the threshold is reached, the case shows an escalation recommendation
   and the contributing signals.
4. A support manager approves or dismisses the recommendation.
5. The decision and reason are recorded for later review.

## Success measures

- Reduce median time from qualifying risk to engineering escalation by 30%.
- Do not increase false escalations by more than 10% compared with the current
  baseline.
- Produce a recommendation within two minutes of a qualifying case update.
- Give pilot support managers enough explanation to understand the
  recommendation.

## Non-goals

- Autonomous engineer paging.
- Automatic customer communication.
- Automatic case-severity changes.
- Global rollout.
- Replacing the existing case-management platform.

## Open business questions

- What is the final pilot threshold?
- Which regulated-customer workflows require additional approval?
- How long should decision records be retained?
- What data may be included in operational telemetry?

