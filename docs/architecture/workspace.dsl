workspace "Issue factory" "Target architecture: the parts of the factory and who they talk to." {

    !identifiers flat
    !impliedRelationships true

    model {
        issueAuthor = person "Issue author" "Writes the issue and adds the factory label." "Human"
        reviewer = person "Reviewer" "Reviews the pull request and decides whether to merge." "Human"
        factoryEngineer = person "Factory engineer" "Changes the factory definition and compares versions." "Human"

        github = softwareSystem "GitHub" "Issues, repositories, pull requests and their checks." "External"
        agentCore = softwareSystem "AWS Bedrock AgentCore Runtime" "Hosts each run's agent session in an isolated microVM. One runtime version per factory version." "External"
        modelVendors = softwareSystem "Model vendors" "Anthropic in the first version; OpenAI later." "External"

        factory = softwareSystem "Issue factory" "Turns a labelled GitHub issue into one pull request." {
            webhookReceiver = container "Webhook receiver" "Verifies GitHub webhooks and queues the events." "AWS Lambda Event Function with a function URL"
            eventQueue = container "Event queue" "Holds events until the handler processes them." "AWS SQS" "Queue"
            deadLetterQueue = container "Dead-letter queue" "Holds events the handler repeatedly fails to process." "AWS SQS" "Queue"
            eventHandler = container "Event handler" "Starts a run when the label is added and no run is active. Records the result when a run's pull request is merged or closed." "AWS Lambda Event Function"
            run = container "Run" "Starts the agent session for the chosen version, opens the pull request and posts progress. Ends when the pull request opens or the run fails." "AWS Lambda durable function, one execution per run"
            agentSandbox = container "Agent sandbox" "The run's agent: a harness and the definition's files, working on a checkout of the repository." "Claude Agent SDK in one container image per factory version"
            runRecord = container "Run record" "What ran, on what, the session's time and cost, and the outcome. Knows whether an issue has an active run." "AWS DynamoDB" "Database"
            definition = container "Factory definition" "Instructions, skills, hooks, harness and model. Each semver tag builds the sandbox image for that version." "GitHub repository"
        }

        issueAuthor -> github "Writes the issue and adds the label"
        reviewer -> github "Reviews and merges"
        factoryEngineer -> factory "Changes the definition and compares versions"
        github -> factory "Sends issue and pull request events" "GitHub App webhook" "Webhook"
        factory -> github "Pushes the run branch, opens the pull request, posts progress, reads check results" "Git, REST"
        factory -> agentCore "Runs the agent session" "AgentCore API"
        factory -> modelVendors "Runs the agent loop" "Model inference"
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
        run -> github "Mints the run's token, opens the pull request, posts progress on the issue" "REST"
        run -> agentCore "Starts the session at the version's endpoint; reads back its events, result and cost" "AgentCore API"
        run -> runRecord "Writes versions, inputs, time and cost, outcome"

        agentCore -> agentSandbox "Runs the session"
        agentSandbox -> github "Clones the repository and pushes the run branch" "Git"
        agentSandbox -> modelVendors "Runs the agent loop" "Model inference"
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
