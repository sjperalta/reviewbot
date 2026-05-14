## ADDED Requirements

### Requirement: System uses SQLite for persistence
The system SHALL use SQLite via the sqlite3 gem for all persistent data storage.

#### Scenario: Database initialization
- **WHEN** the system starts for the first time
- **THEN** it creates a SQLite database at `~/.reviewbot/reviewbot.db`
- **THEN** it runs schema migrations to create all required tables
- **THEN** it confirms the database is ready

### Requirement: System stores repository records
The system SHALL record known repositories with their remote URLs, local paths, and detected stack profiles.

#### Scenario: Store repository
- **WHEN** a repository is reviewed for the first time
- **THEN** the system creates a repository record with remote URL, owner, name, and local path
- **THEN** the system updates the stack profile if detection runs again

### Requirement: System stores pull request records
The system SHALL record pull request metadata including number, title, author, base SHA, head SHA, and status.

#### Scenario: Store pull request
- **WHEN** a PR is fetched from GitHub
- **THEN** the system creates or updates the PR record
- **THEN** the record includes PR number, title, author, base branch, head branch, and latest commit SHA

### Requirement: System stores review runs
The system SHALL record each review execution with timestamps, commit SHA, and result summary.

#### Scenario: Store review run
- **WHEN** a review completes
- **THEN** the system creates a review run record linked to the PR
- **THEN** the record includes review timestamp, head commit SHA, risk level, finding count, and AI model used

### Requirement: System stores findings
The system SHALL persist each AI-generated finding with severity, file path, title, description, and suggestion.

#### Scenario: Store finding
- **WHEN** a finding is generated
- **THEN** the system creates a finding record linked to the review run
- **THEN** the record includes severity, file path, line number, title, description, suggestion, and finding category

### Requirement: System caches diffs
The system SHALL cache processed diffs keyed by PR number and commit SHA to avoid reprocessing.

#### Scenario: Cache diff
- **WHEN** a diff is fetched and parsed for a PR
- **THEN** the system stores the parsed diff chunks keyed by PR number and head commit SHA
- **THEN** subsequent reviews with the same commit SHA use the cached diff

### Requirement: System supports cache clearing
The system SHALL provide a mechanism to clear cached data while preserving persistent review records.

#### Scenario: Clear cache
- **WHEN** `reviewbot cache:clear` is executed
- **THEN** the system truncates the cached diffs table
- **THEN** the system preserves repository, PR, review, and finding records
- **THEN** the system vacuums the database to reclaim space
