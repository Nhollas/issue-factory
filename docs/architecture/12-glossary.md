# 12. Glossary

| Term | Definition |
| --- | --- |
| Active run | A run whose durable execution has the status `RUNNING`, `PAUSING` or `PAUSED`. |
| Agent | The harness session that works on the issue. In the first version, a Claude Agent SDK session. |
| Agent runner | The factory's program in the sandbox image. It clones the factory definition, starts the agent session and completes the run's callback. |
| Agent session | One execution of the agent, from start to result message. |
| Base commit | The commit on the default branch that a run starts from. |
| Callback | A durable function operation. The run creates it and suspends until the agent runner completes it. |
| Callback message | The message that the agent runner sends when it completes the callback. |
| Claim | The item in the run record that names an issue's current run. |
| Contract | The three messages between the run and the agent runner: start request, structured output and callback message. |
| Durable execution | One execution of an AWS Lambda durable function. Each run is one durable execution. |
| Event handler | The Lambda function that starts runs and adds pull request results to the run record. |
| Factory | The whole system: a labelled issue goes in and one pull request comes out. |
| Factory definition | The versioned files that set up the agent: a plugin and a settings file. |
| Factory version | One semver tag of the factory definition. |
| Harness | The program that runs the agent loop, such as the Claude Agent SDK. |
| Heartbeat | A signal that the agent runner sends to the callback while the agent works. |
| Outcome | How a run ended: `factory:done`, `factory:declined` or `factory:failed`. |
| Plugin | A Claude plugin: a directory of skills, hooks, agents and MCP server definitions that the Claude Agent SDK loads. |
| Run | One attempt to turn one issue into one pull request. One durable execution. |
| Run branch | The branch that one run's agent pushes. |
| Run record | The DynamoDB table that stores one record per run and one claim per issue. |
| Sandbox | The isolated microVM on AgentCore Runtime that runs the sandbox image for one run. |
| Settings file | The file in the factory definition that holds the model, the turn limit and the budget limit. |
| Start request | The message that the run sends to the agent runner to start the agent session. |
| Structured output | The object that the agent ends its session with: `outcome` and `summary`. |
| Webhook receiver | The Lambda function that verifies GitHub webhooks and puts events on the event queue. |
