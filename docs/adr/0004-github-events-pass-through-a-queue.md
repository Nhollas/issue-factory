---
status: accepted
---

# GitHub events pass through a queue

GitHub expects a quick reply to a webhook. Starting a run takes several calls and can fail part-way.

## Decision

- The webhook receiver only verifies the webhook signature and puts the event on an SQS queue.
- The event handler does the work. SQS retries a failed event and moves it to a dead-letter queue after too many receives.
- The webhook receiver is a Lambda function with a public function URL. GitHub cannot sign requests with AWS credentials, so the receiver checks GitHub's webhook signature.

## Consequences

- The event handler must be safe to run twice on the same event. The execution name contains the delivery ID for that reason.
- The factory does not recover a delivery that GitHub failed to deliver. A scheduled redelivery job can be added later.
