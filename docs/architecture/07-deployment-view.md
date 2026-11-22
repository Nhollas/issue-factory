# 7. Deployment view

## Decided

| Container | Deployed as |
| --- | --- |
| Webhook receiver | An AWS Lambda function with a public function URL. |
| Event queue, dead-letter queue | AWS SQS queues. The event handler receives events through an event source mapping. |
| Event handler | An AWS Lambda function. |
| Run | An AWS Lambda durable function. Each run is one execution. |
| Run record | An AWS DynamoDB table. |
| Agent sandbox | One container image on AgentCore Runtime. The image deploys together with the run. |
| Factory definition | A GitHub repository. A semver tag is one factory version. Tagging deploys nothing. |

## Not yet designed

- AWS accounts and regions.
- Environments.
- Infrastructure as code.
- The pipeline that deploys the sandbox image and the factory's own code together.
- The GitHub App: its permissions, its installation and its webhook configuration.
