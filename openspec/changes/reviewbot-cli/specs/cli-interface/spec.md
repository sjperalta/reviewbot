## ADDED Requirements

### Requirement: CLI provides a `reviewbot prs` command
The system SHALL list all open GitHub Pull Requests assigned to the current user for review.

#### Scenario: List assigned PRs
- **WHEN** user runs `reviewbot prs`
- **THEN** the system fetches PRs via `gh pr list --search "review-requested:@me is:open"`
- **THEN** the system displays a formatted table with PR number, title, repository, and author

### Requirement: CLI provides a `reviewbot review PR_NUMBER` command
The system SHALL review a specific pull request by number.

#### Scenario: Review a specific PR
- **WHEN** user runs `reviewbot review 123`
- **THEN** the system fetches PR #123
- **THEN** the system runs repository detection, static analysis, and AI review
- **THEN** the system displays findings summary in the terminal

### Requirement: CLI provides a `reviewbot review --all` command
The system SHALL review all open PRs assigned to the current user sequentially.

#### Scenario: Review all assigned PRs
- **WHEN** user runs `reviewbot review --all`
- **THEN** the system iterates through all assigned PRs
- **THEN** each PR is reviewed in sequence with progress indication

### Requirement: CLI provides a `reviewbot publish PR_NUMBER` command
The system SHALL publish review findings as GitHub pull request review comments.

#### Scenario: Publish review to GitHub
- **WHEN** user runs `reviewbot publish 123`
- **THEN** the system retrieves the latest review for PR #123
- **THEN** the system posts findings as GitHub PR review comments via Octokit
- **THEN** the system confirms publication with a success message

### Requirement: CLI provides a `reviewbot export PR_NUMBER` command
The system SHALL export the latest review for a PR as a markdown file.

#### Scenario: Export review to markdown
- **WHEN** user runs `reviewbot export 123`
- **THEN** the system generates a markdown report file
- **THEN** the system writes the file to `./reviews/pr-123-review.md`
- **THEN** the system displays the file path

### Requirement: CLI provides a `reviewbot cache:clear` command
The system SHALL clear all cached data from the SQLite database.

#### Scenario: Clear cache
- **WHEN** user runs `reviewbot cache:clear`
- **THEN** the system truncates cached diffs and temporary data
- **THEN** the system preserves persistent review data
- **THEN** the system confirms with a success message

### Requirement: CLI displays color-coded severity levels
The system SHALL use pastel colors to indicate finding severity (low/green, medium/yellow, high/red, critical/magenta).

#### Scenario: Color-coded output
- **WHEN** the system displays findings
- **THEN** low severity findings SHALL be shown in green
- **THEN** medium severity findings SHALL be shown in yellow
- **THEN** high severity findings SHALL be shown in red
- **THEN** critical severity findings SHALL be shown in magenta

### Requirement: CLI shows progress spinners during long operations
The system SHALL display tty-spinner animations during PR fetching, checkout, analysis, and AI review.

#### Scenario: Spinner during review
- **WHEN** user runs a review command
- **THEN** the system shows spinners for each phase: fetching, checking out, analyzing, reviewing
- **THEN** spinners resolve with success/failure indication
