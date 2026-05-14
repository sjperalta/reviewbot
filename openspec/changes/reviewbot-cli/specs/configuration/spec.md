## ADDED Requirements

### Requirement: System reads configuration from `.env` file
The system SHALL load environment variables from a `.env` file in the project root using the dotenv gem.

#### Scenario: Load .env
- **WHEN** the system starts
- **THEN** it loads `.env` from the current working directory
- **THEN** `GITHUB_TOKEN`, `DEEPSEEK_API_KEY`, and `DEFAULT_BASE_BRANCH` are available as environment variables

### Requirement: System supports required environment variables
The system SHALL validate that required environment variables are set and provide clear error messages when missing.

#### Scenario: Missing required variable
- **WHEN** `GITHUB_TOKEN` is not set
- **THEN** the system prints an error message indicating the missing variable
- **THEN** the system exits with a non-zero code

#### Scenario: Missing DeepSeek API key
- **WHEN** `DEEPSEEK_API_KEY` is not set
- **THEN** the system prints a warning
- **THEN** the system continues with static analysis only (no AI review)

### Requirement: System reads repository configuration from `.reviewbot.yml`
The system SHALL read per-repository configuration from a `.reviewbot.yml` file in the repository root.

#### Scenario: Load repository config
- **WHEN** reviewing a repository
- **THEN** the system checks for `.reviewbot.yml` in the repository root
- **THEN** if present, the system parses the YAML configuration
- **THEN** the configuration affects reviewer selection, rules, and ignore patterns

### Requirement: System supports `.reviewbot.yml` stack configuration
The `.reviewbot.yml` SHALL support explicit `stack:` declaration to override auto-detection.

#### Scenario: Explicit stack configuration
- **WHEN** `.reviewbot.yml` specifies a stack (e.g., `stack: [rails, react, typescript]`)
- **THEN** the system uses the declared stack instead of auto-detection
- **THEN** the appropriate reviewers and analyzers are selected

### Requirement: System supports `.reviewbot.yml` rules configuration
The `.reviewbot.yml` SHALL support custom rules that influence AI review prompts.

#### Scenario: Custom rules in prompt
- **WHEN** `.reviewbot.yml` contains `rules:` (e.g., `require_transactions_for_payments: true`)
- **THEN** the system includes these rules in the repository prompt layer for the AI
- **THEN** the AI incorporates these rules into its review criteria

### Requirement: System supports `.reviewbot.yml` ignore patterns
The `.reviewbot.yml` SHALL support `ignore:` patterns to exclude files from AI review.

#### Scenario: Ignore files from review
- **WHEN** `.reviewbot.yml` lists files or patterns under `ignore:`
- **THEN** the system excludes matching files from the diff sent to AI
- **THEN** matching files are still included in static analysis where applicable

### Requirement: CLI flags override file-based configuration
The system SHALL allow CLI flags to override `.env` and `.reviewbot.yml` settings.

#### Scenario: CLI flag override
- **WHEN** a CLI flag is provided (e.g., `--base-branch develop`)
- **THEN** the CLI flag value takes precedence over config file values
- **THEN** CLI flags override environment variable defaults
