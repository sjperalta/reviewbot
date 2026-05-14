## ADDED Requirements

### Requirement: System runs Rubocop on Ruby projects
The system SHALL execute Rubocop on Ruby and Rails repositories to detect style and code quality issues.

#### Scenario: Run Rubocop analysis
- **WHEN** the repository is detected as Ruby or Rails
- **THEN** the system runs `rubocop --format json` on the changed files or whole project
- **THEN** the system parses the JSON output into structured findings

### Requirement: System runs Brakeman on Rails projects
The system SHALL run Brakeman security analysis on Rails repositories.

#### Scenario: Run Brakeman analysis
- **WHEN** the repository is detected as Rails
- **THEN** the system runs `brakeman --format json`
- **THEN** the system parses warnings into structured findings with severity levels

### Requirement: System runs Reek on Ruby projects
The system SHALL run Reek code smell detector on Ruby repositories.

#### Scenario: Run Reek analysis
- **WHEN** the repository is detected as Ruby or Rails
- **THEN** the system runs `reek --format json` on changed files
- **THEN** the system parses code smell warnings into structured findings

### Requirement: System runs ESLint on JavaScript/TypeScript projects
The system SHALL run ESLint on JavaScript and TypeScript repositories.

#### Scenario: Run ESLint analysis
- **WHEN** the repository has JavaScript or TypeScript files
- **THEN** the system runs `eslint --format json` on the changed files
- **THEN** the system parses lint violations into structured findings

### Requirement: System runs TypeScript compiler check
The system SHALL run `tsc --noEmit` on TypeScript repositories to detect type errors.

#### Scenario: Run TypeScript check
- **WHEN** TypeScript is detected in the repository
- **THEN** the system runs `npx tsc --noEmit` on the project
- **THEN** the system parses compiler errors into structured findings

### Requirement: System runs `dart analyze` on Dart projects
The system SHALL run `dart analyze` on Dart and Flutter repositories.

#### Scenario: Run dart analysis
- **WHEN** Dart or Flutter is detected in the repository
- **THEN** the system runs `dart analyze` on the project
- **THEN** the system parses analysis results into structured findings

### Requirement: System runs `golangci-lint` on Go projects
The system SHALL run `golangci-lint` on Go repositories.

#### Scenario: Run golangci-lint
- **WHEN** Go is detected in the repository
- **THEN** the system runs `golangci-lint run --out-format json` on the project
- **THEN** the system parses lint warnings into structured findings

### Requirement: System runs `go vet` on Go projects
The system SHALL run `go vet` on Go repositories to detect suspicious constructs.

#### Scenario: Run go vet
- **WHEN** Go is detected in the repository
- **THEN** the system runs `go vet ./...` on the project
- **THEN** the system parses vet warnings into structured findings

### Requirement: System gracefully handles missing analyzer tools
The system SHALL skip analysis tools that are not installed and report a warning.

#### Scenario: Missing analyzer tool
- **WHEN** an analyzer command is not found in PATH
- **THEN** the system logs a warning message
- **THEN** the system continues with available analyzers
- **THEN** the system notes the missing tool in the review report

### Requirement: System parses analyzer output into structured findings
All static analysis results SHALL be parsed into a uniform finding format with severity, file, line, message, and tool source.

#### Scenario: Parse analysis results
- **WHEN** analyzer output is received
- **THEN** the system maps tool-specific severity to the standard model (low/medium/high/critical)
- **THEN** findings include the source tool name for attribution
- **THEN** findings are stored in the database and available for AI context
