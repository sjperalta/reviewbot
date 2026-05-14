## ADDED Requirements

### Requirement: System fetches PR metadata via Octokit
The system SHALL use the Octokit Ruby gem to retrieve PR title, description, labels, author, and changed files list.

#### Scenario: Fetch PR metadata
- **WHEN** the system processes a pull request
- **THEN** it fetches PR title, body, labels, user, and changed files via Octokit
- **THEN** it structures the data for use by the review pipeline

### Requirement: System fetches PR commit history
The system SHALL retrieve the commit history for a PR, including commit messages, authors, and SHA hashes.

#### Scenario: Fetch commit history
- **WHEN** the system needs commit context for a review
- **THEN** it fetches commits via Octokit `pull_request_commits`
- **THEN** commit messages are included in the AI review context

### Requirement: System fetches PR diff
The system SHALL retrieve the unified diff for the pull request.

#### Scenario: Fetch PR diff
- **WHEN** the system needs diff content for review
- **THEN** it retrieves the diff via Octokit or by running `git diff <base>...<head>`
- **THEN** the diff is parsed into per-file chunks for processing

### Requirement: System publishes review comments to GitHub
The system SHALL submit review findings as a PR review via Octokit's `create_pull_request_review` API.

#### Scenario: Publish review comments
- **WHEN** user runs `reviewbot publish <number>`
- **THEN** the system creates a new PR review with summary comment
- **THEN** inline comments are posted on specific lines where applicable
- **THEN** the review event is set to `COMMENT` (not APPROVE or REQUEST_CHANGES)

### Requirement: System handles GitHub API rate limits
The system SHALL respect GitHub API rate limits with exponential backoff and caching.

#### Scenario: Rate limit handling
- **WHEN** GitHub API returns a 429 or 403 rate limit response
- **THEN** the system waits the duration specified in the `Retry-After` header
- **THEN** the system retries the request
- **THEN** if the limit persists, the system logs a warning and uses cached data

### Requirement: System supports multiple GitHub organizations
The system SHALL work with repositories across multiple GitHub organizations.

#### Scenario: Cross-organization access
- **WHEN** the authenticated user has access to multiple organizations
- **THEN** the system lists PRs from all accessible repositories
- **THEN** the system checks out and reviews PRs from any accessible repo
