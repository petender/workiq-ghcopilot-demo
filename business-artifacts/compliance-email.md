# Email: Compliance constraints for escalation pilot

**Project marker:** Project Northstar Escalation  
**From:** Priya Shah, Compliance  
**To:** Maya Chen; Evan Brooks; Luis Ortega  
**Subject:** Compliance constraints for Project Northstar Escalation pilot  
**Sent:** September 18, 2026, 2:30 PM  
**Purpose:** Fictional email to stage in Outlook

Team,

Before engineering starts the Intelligent Escalation pilot, please include the
following constraints in the implementation requirements:

1. Do not put raw customer message text, attachments, or message excerpts in
   model or application telemetry.
2. Retain the recommendation, contributing signal categories, final decision,
   override reason when applicable, timestamp, and approving manager identity
   for 13 months.
3. Encrypt audit records in transit and at rest using approved enterprise
   controls.
4. A manager who dismisses or overrides a recommendation must select or enter
   a reason.
5. Operations needs an emergency kill switch that disables new
   recommendations without a deployment.
6. Pilot reporting may use aggregated metrics, but it must not expose customer
   message content or directly identify individual customers.

These controls apply to the pilot. They do not authorize broader data
collection or a production rollout.

Thanks,  
Priya

