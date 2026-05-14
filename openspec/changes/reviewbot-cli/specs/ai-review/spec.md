## ADDED Requirements

### Requirement: System connects to DeepSeek API
The system SHALL send review requests to the DeepSeek API using the configured API key.

#### Scenario: Send review request
- **WHEN** the system has assembled review context
- **THEN** it sends a POST request to `https://api.deepseek.com/v1/chat/completions`
- **THEN** the request includes the assembled prompt layers and structured output format instruction
- **THEN** the system sets an appropriate timeout for the request

### Requirement: System implements retry logic with exponential backoff
The system SHALL retry failed API requests up to 3 times with exponential backoff.

#### Scenario: Retry on API failure
- **WHEN** the API returns a 5xx error or network timeout
- **THEN** the system waits 1 second before the first retry
- **THEN** the system waits 2 seconds before the second retry
- **THEN** the system waits 4 seconds before the third retry
- **THEN** if all retries fail, the system reports the error and continues with partial results

### Requirement: System enforces token budgets for AI requests
The system SHALL calculate and enforce token limits to prevent exceeding the model's context window.

#### Scenario: Token budget enforcement
- **WHEN** assembling the review context
- **THEN** the system estimates token count for each context component
- **THEN** if the total exceeds the budget (e.g., 32K tokens for DeepSeek), the system prioritizes and truncates lower-value components
- **THEN** binary, generated, lockfile, vendor, and snapshot files are always excluded

### Requirement: System processes diffs in chunks for large PRs
The system SHALL split large diffs into chunks and process them in parallel when possible.

#### Scenario: Chunked diff processing
- **WHEN** the total diff exceeds the token budget
- **THEN** the system divides changed files into logical chunks (by file, directory, or change type)
- **THEN** each chunk is reviewed independently
- **THEN** results are merged into a unified review with deduplication

### Requirement: System parses structured JSON from AI responses
The system SHALL parse AI responses as structured JSON conforming to the expected review format.

#### Scenario: Parse AI response
- **WHEN** the AI responds with a JSON review object
- **THEN** the system validates the JSON structure
- **THEN** the system extracts summary, risk_level, findings, missing_tests, architecture_notes, and security_notes
- **THEN** if JSON parsing fails, the system logs the raw response and attempts to extract findings via regex fallback

### Requirement: System uses layered prompting strategy
The system SHALL assemble prompts in layers: System → Language → Repository → PR Context.

#### Scenario: Assemble layered prompt
- **WHEN** preparing the AI request
- **THEN** the system prompt defines review philosophy, severity model, and output format
- **THEN** the language prompt adds framework-specific expertise and best practices
- **THEN** the repository prompt adds project-specific conventions and rules from `.reviewbot.yml`
- **THEN** the PR context prompt adds the actual diff, changed files, PR description, and commit messages

### Requirement: System implements review caching
The system SHALL cache AI review results to avoid re-reviewing unchanged PRs.

#### Scenario: Cache hit
- **WHEN** a PR has been reviewed before
- **AND** the latest commit SHA matches the cached review
- **THEN** the system returns cached results instead of calling the AI
- **THEN** the system indicates results are from cache

#### Scenario: Cache miss
- **WHEN** a PR has new commits since the last review
- **THEN** the system performs a new AI review
- **THEN** the system updates the cache with the new commit SHA and results

### Requirement: System supports incremental review
The system SHALL only re-review files that changed in new commits when a PR has been previously reviewed.

#### Scenario: Incremental review
- **WHEN** reviewing a PR with prior cached results
- **AND** only a subset of files changed in new commits
- **THEN** the system re-reviews only the changed files
- **THEN** the system merges new findings with cached findings, removing any that apply to re-reviewed files
