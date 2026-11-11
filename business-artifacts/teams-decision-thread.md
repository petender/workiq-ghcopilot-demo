# Teams Decision Thread: Intelligent Escalation

**Project marker:** Project Northstar Escalation  
**Team/channel:** Support Transformation / Intelligent Escalation decisions  
**Thread date:** September 15, 2026  
**Purpose:** Fictional transcript to stage as a Teams channel conversation

## Thread

**Maya Chen, 9:02 AM**

I want to close the pilot decisions from last week's review. The business brief
still says a risk score of 70. Operations testing showed too many marginal
cases at that level.

**Luis Ortega, Support Operations, 9:05 AM**

Agreed. For the North America enterprise pilot, use **80** as the recommendation
threshold. This supersedes the 70 in the brief. We can revisit the threshold
after we have pilot evidence.

**Maya Chen, 9:07 AM**

Decision recorded: threshold 80 for the pilot. Please make the source conflict
obvious in the engineering spec so reviewers do not implement the old value.

**Priya Shah, Compliance, 9:11 AM**

Regulated customers need a support manager's approval before an escalation can
be submitted. A recommendation alone must never trigger the escalation.

**Evan Brooks, Engineering, 9:15 AM**

Can the UI show why the recommendation was made? A score without context will
be difficult to review and troubleshoot.

**Maya Chen, 9:17 AM**

Yes. Show the contributing signals, but do not expose internal weighting or
raw customer message text. Severity, customer tier, sentiment category, and
repeat-contact count are enough for the pilot.

**Luis Ortega, 9:21 AM**

Rollout decision: place the capability behind a feature flag and start with 20
support agents plus their managers. Operations must be able to disable it
without a deployment.

**Maya Chen, 9:24 AM**

Approved. Those are the final pilot decisions. Engineering can leave the exact
scoring formula and feature-flag platform as open technical questions.

## Decisions to preserve

- Risk threshold 80 supersedes 70 in the SharePoint brief.
- A support manager approves every recommendation; regulated cases must never
  bypass this step.
- Show contributing signal values but not internal weights or raw message text.
- Use a feature flag and begin with 20 agents plus their managers.
- Keep the scoring formula and flag platform as open technical questions.

