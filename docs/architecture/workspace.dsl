workspace "Issue factory" "Target architecture: the parts of the factory and who they talk to." {

    !identifiers flat
    !impliedRelationships true

    model {
        issueAuthor = person "Issue author" "Writes the issue and adds the factory label." "Human"
        reviewer = person "Reviewer" "Reviews the pull request and decides whether to merge." "Human"
        factoryEngineer = person "Factory engineer" "Changes the factory definition and compares versions." "Human"

        github = softwareSystem "GitHub" "Issues, repositories, pull requests and their checks." "External"
        agentCore = softwareSystem "AWS Bedrock AgentCore Runtime" "Hosts each run's agent session in an isolated microVM." "External"
        modelVendors = softwareSystem "Model vendors" "Anthropic API in the first version; OpenAI later." "External"

        factory = softwareSystem "Issue factory" "Turns a labelled GitHub issue into one pull request." {
            webhookReceiver = container "Webhook receiver" "Verifies GitHub webhooks and queues the events." "AWS Lambda Event Function with a function URL"
            eventQueue = container "Event queue" "Holds events until the handler processes them." "AWS SQS" "Queue"
            deadLetterQueue = container "Dead-letter queue" "Holds events the handler repeatedly fails to process." "AWS SQS" "Queue"
            eventHandler = container "Event handler" "Starts a run when the label is added and no run is active. Records the result when a run's pull request is merged or closed." "AWS Lambda Event Function"
            run = container "Run" "Starts the agent session for the chosen version, opens the pull request and posts progress. Ends when the pull request opens or the run fails." "AWS Lambda durable function, one execution per run"
            agentSandbox = container "Agent sandbox" "The agent runner clones the factory definition, starts the Claude Agent SDK session and reports its result to the run. The agent works on a checkout of the repository." "Claude Agent SDK in one container image"
            runRecord = container "Run record" "What ran, on what, the session's time and cost, and the outcome. Knows whether an issue has an active run." "AWS DynamoDB" "Database"
            definition = container "Factory definition" "A Claude plugin and a settings file. Each semver tag is one factory version." "GitHub repository"
        }

        issueAuthor -> github "Writes the issue and adds the label"
        reviewer -> github "Reviews and merges"
        factoryEngineer -> factory "Changes the definition and compares versions"
        github -> factory "Sends issue and pull request events" "GitHub App webhook" "Webhook"
        factory -> github "Pushes the run branch, opens the pull request, posts progress, reads check results" "Git, REST"
        factory -> agentCore "Runs the agent session" "AgentCore API"
        factory -> modelVendors "Runs the agent loop" "Anthropic API key"
        factoryEngineer -> definition "Changes and tags the definition" "Git"
        factoryEngineer -> runRecord "Compares versions"

        github -> webhookReceiver "Sends issue and pull request events" "GitHub App webhook" "Webhook"
        webhookReceiver -> eventQueue "Queues verified events" "SQS"
        eventQueue -> deadLetterQueue "Moves events received too many times" "SQS redrive"
        eventHandler -> eventQueue "Receives events" "Event source mapping"
        eventHandler -> runRecord "Checks for an active run; adds the pull request's result"
        eventHandler -> github "Reads check results" "REST"
        eventHandler -> run "Starts a run" "Lambda invoke"

        run -> definition "Resolves the chosen version, or the newest tag" "Git"
        run -> github "Mints the run's token, checks the run branch, opens the pull request, posts progress" "REST"
        run -> agentCore "Starts the session with the start request" "AgentCore API"
        run -> runRecord "Writes versions, inputs, time and cost, outcome"

        agentCore -> agentSandbox "Runs the session"
        agentSandbox -> definition "Clones the definition at the run's tag" "Git"
        agentSandbox -> github "Clones the repository and pushes the run branch" "Git"
        agentSandbox -> modelVendors "Runs the agent loop" "Anthropic API key"
        agentSandbox -> run "Completes the run's callback with the session result" "Durable callback API"
    }

    views {
        properties {
            "c4plantuml.tags" "true"
            "c4plantuml.legend" "true"
        }

        systemContext factory "Context" {
            title "Issue factory: people and systems around it"
            include * issueAuthor reviewer
            exclude "agentCore -> factory"
            autoLayout tb
        }

        container factory "Containers" {
            title "Issue factory: parts and external systems"
            include *
            autoLayout tb
        }

        styles {
            element "Element" {
                color #ffffff
                stroke #2b2b2b
                strokeWidth 2
                fontSize 22
            }
            element "Person" {
                shape person
                background #4a6fa5
            }
            element "Software System" {
                background #34558b
            }
            element "Container" {
                background #4a6fa5
            }
            element "External" {
                background #7f7f7f
            }
            element "Human" {
                background #4aa563
            }
            element "Database" {
                shape cylinder
            }
            element "Queue" {
                shape pipe
            }
            relationship "Relationship" {
                thickness 2
                fontSize 20
                style solid
                color #2b2b2b
            }
            relationship "Webhook" {
                style dashed
            }
        }
    }
}
