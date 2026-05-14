## ADDED Requirements

### Requirement: Pipeline orchestrates the full review workflow
The system SHALL orchestrate repository detection, diff extraction, static analysis, AI review, and result formatting as a sequential pipeline with parallel sub-steps.

#### Scenario: Full pipeline execution
- **WHEN** a PR is selected for review
- **THEN** the system detects the repository stack
- **THEN** the system extracts the diff and categorizes changed files
- **THEN** the system runs appropriate static analyzers in parallel
- **THEN** the system assembles review context from all sources
- **THEN** the system sends the context to the AI for review
- **THEN** the system formats and stores the results

### Requirement: Pipeline selects the appropriate language reviewer
The system SHALL instantiate the correct reviewer class based on the detected repository profile.

#### Scenario: Reviewer selection
- **WHEN** the repository profile is built
- **THEN** the system selects the matching reviewer for the primary stack
- **THEN** for monorepos, the system runs reviewers for each detected stack

### Requirement: Pipeline filters and categorizes changed files
The system SHALL categorize changed files into meaningful groups (source, test, config, generated, binary, vendor, etc.).

#### Scenario: File categorization
- **WHEN** extracting the diff
- **THEN** the system classifies each file by extension and path
- **THEN** binary, generated, lockfile, vendor, and snapshot files are excluded from AI review
- **THEN** source files are prioritized for review
- **THEN** test files are reviewed with different heuristics (test quality focus)

### Requirement: Pipeline assembles structured review context
The system SHALL combine repository profile, PR metadata, categorized diffs, and static analysis results into a structured context object for the AI.

#### Scenario: Context assembly
- **WHEN** all data sources are ready
- **THEN** the system creates a context object with repository profile, PR info, file diffs, static analysis findings, and commit history
- **THEN** the context is formatted into the layered prompt structure
- **THEN** the context is sent to the AI review engine

### Requirement: Pipeline stores review results in the database
The system SHALL persist review results including findings, risk level, and metadata to SQLite.

#### Scenario: Store results
- **WHEN** the AI review completes
- **THEN** the system creates a review run record in the database
- **THEN** the system stores each finding with severity, file, title, description, and suggestion
- **THEN** the system links findings to the review run

### Requirement: Pipeline provides progress callbacks for terminal UI
The system SHALL emit progress events during pipeline execution for display by the CLI.

#### Scenario: Progress reporting
- **WHEN** each pipeline phase starts
- **THEN** the system emits a start event with phase name
- **THEN** when the phase completes, the system emits a complete event
- **THEN** on failure, the system emits a failure event with error details

### Requirement: Ruby/Rails pipeline includes specialized review rules
The Ruby/Rails pipeline SHALL include review focus on N+1 queries, transaction safety, callback abuse, and fat controllers.

#### Scenario: Rails review focus
- **WHEN** the repository is detected as Rails
- **THEN** the language prompt includes Rails-specific review heuristics
- **THEN** static analysis includes Rubocop with Rails and RSpec cops, Brakeman, and Reek

### Requirement: JavaScript/TypeScript pipeline includes specialized review rules
The JS/TS pipeline SHALL include review focus on async bugs, React hooks, state management, and type safety.

#### Scenario: JS/TS review focus
- **WHEN** JavaScript or TypeScript is detected
- **THEN** the language prompt includes JS/TS/React-specific review heuristics
- **THEN** static analysis includes ESLint with appropriate plugins and TypeScript compiler

### Requirement: Flutter/Dart pipeline includes specialized review rules
The Flutter/Dart pipeline SHALL include review focus on widget rebuilds, state management, and memory leaks.

#### Scenario: Flutter review focus
- **WHEN** Flutter or Dart is detected
- **THEN** the language prompt includes Flutter/Dart-specific review heuristics
- **THEN** static analysis includes `dart analyze`

### Requirement: Go pipeline includes specialized review rules
The Go pipeline SHALL include review focus on goroutine leaks, context propagation, and error handling.

#### Scenario: Go review focus
- **WHEN** Go is detected
- **THEN** the language prompt includes Go-specific review heuristics
- **THEN** static analysis includes `golangci-lint` and `go vet`
