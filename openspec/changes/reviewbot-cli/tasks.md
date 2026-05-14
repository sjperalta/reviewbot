## 1. Project Setup

- [x] 1.1 Create Gemfile with all dependencies (thor, octokit, faraday, concurrent-ruby, sqlite3, tty-prompt, tty-table, tty-spinner, pastel, dotenv, psych)
- [x] 1.2 Create full directory structure under `lib/reviewbot/`: cli/, github/, git/, ai/, pipelines/, reviewers/, analyzers/, services/, formatters/, cache/, models/, config/, utils/
- [x] 1.3 Create project entrypoint `exe/reviewbot` with executable shebang
- [x] 1.4 Create initial `lib/reviewbot.rb` entrypoint that requires all components
- [x] 1.5 Create `.env.example` with GITHUB_TOKEN, DEEPSEEK_API_KEY, DEFAULT_BASE_BRANCH
- [x] 1.6 Create `.reviewbot.yml` example file in the project root
- [x] 1.7 Set up RSpec with spec_helper, WebMock, VCR configuration
- [x] 1.8 Create `.rspec` and `spec/spec_helper.rb` with test configuration

## 2. Configuration System

- [x] 2.1 Implement `Config::Loader` class that loads `.env` via dotenv and provides access to environment variables
- [x] 2.2 Implement `Config::RepositoryConfig` class that parses `.reviewbot.yml` and provides stack, rules, and ignore patterns
- [x] 2.3 Implement `Config::Options` value object that merges CLI flags, env vars, and file config with precedence
- [x] 2.4 Implement `Config::Validator` that checks required env vars (GITHUB_TOKEN, DEEPSEEK_API_KEY) and provides clear error messages
- [x] 2.5 Implement `Config::Defaults` module with sensible default values (base branch, output dir, etc.)

## 3. Database Layer

- [x] 3.1 Implement `Cache::Database` class that manages SQLite connection, creates `~/.reviewbot/` directory, and initializes schema
- [x] 3.2 Create database schema migration for `repositories` table (id, owner, name, remote_url, local_path, stack_profile, created_at, updated_at)
- [x] 3.3 Create database schema migration for `pull_requests` table (id, repo_id, number, title, author, base_branch, head_branch, head_sha, state, created_at, updated_at)
- [x] 3.4 Create database schema migration for `review_runs` table (id, pr_id, status, risk_level, finding_count, ai_model, head_sha, started_at, completed_at)
- [x] 3.5 Create database schema migration for `findings` table (id, review_run_id, severity, category, file_path, line_number, title, description, suggestion, source)
- [x] 3.6 Create database schema migration for `cached_diffs` table (id, pr_id, head_sha, diff_data, created_at)
- [x] 3.7 Implement `Models::Repository` value object with to_hash and from_row methods
- [x] 3.8 Implement `Models::PullRequest` value object with to_hash and from_row methods
- [x] 3.9 Implement `Models::ReviewRun` value object with to_hash and from_row methods
- [x] 3.10 Implement `Models::Finding` value object with to_hash and from_row methods
- [x] 3.11 Implement `Cache::Repository` repository class wrapping DB queries for CRUD
- [x] 3.12 Implement `Cache::PullRequest` repository class wrapping DB queries for CRUD
- [x] 3.13 Implement `Cache::ReviewRun` repository class wrapping DB queries for CRUD
- [x] 3.14 Implement `Cache::Finding` repository class wrapping DB queries for CRUD
- [x] 3.15 Implement `Cache::DiffCache` class with get/set/clear methods for cached diffs
- [x] 3.16 Implement `Cache::Manager` facade that coordinates all cache operations

## 4. GitHub Integration

- [x] 4.1 Implement `GitHub::Client` class that wraps Octokit client initialization with GITHUB_TOKEN
- [x] 4.2 Implement `GitHub::PRFetcher` class that fetches PR metadata (title, body, labels, author, files, commits) via Octokit
- [x] 4.3 Implement `GitHub::PRLister` class that calls `gh pr list` CLI and parses JSON output
- [x] 4.4 Implement `GitHub::CommentPublisher` class that posts review findings as PR review comments via Octokit
- [x] 4.5 Implement `GitHub::RateLimiter` class that handles 429/403 responses with backoff
- [x] 4.6 Implement `GitHub::Client` error handling for common API failures
- [x] 4.7 Implement `GitHub::DiffFetcher` that retrieves PR diff via Octokit or git diff

## 5. PR Management

- [x] 5.1 Implement `Git::CLI` class that wraps `gh` and `git` CLI commands with system call execution
- [x] 5.2 Implement `Git::PRChecker` class that checks out PR branch via `gh pr checkout`
- [x] 5.3 Implement `Git::BranchManager` class that records current branch and restores it after review
- [x] 5.4 Implement `Git::RepoManager` class that clones missing repos via `gh repo clone`
- [x] 5.5 Implement `Services::PRSelector` class that provides interactive PR selection via tty-prompt
- [x] 5.6 Implement `Services::PRManager` facade that coordinates PR listing, selection, and checkout

## 6. Repository Detection

- [x] 6.1 Implement `Services::RepoDetector` class that orchestrates full detection workflow
- [x] 6.2 Implement `Services::Detectors::RubyDetector` that checks for Gemfile, config/application.rb
- [x] 6.3 Implement `Services::Detectors::RailsDetector` that checks for Rails-specific files
- [x] 6.4 Implement `Services::Detectors::NodeDetector` that checks for package.json, tsconfig.json, react deps
- [x] 6.5 Implement `Services::Detectors::FlutterDetector` that checks for pubspec.yaml with flutter SDK
- [x] 6.6 Implement `Services::Detectors::DartDetector` that checks for .dart files
- [x] 6.7 Implement `Services::Detectors::GoDetector` that checks for go.mod
- [x] 6.8 Implement `Models::RepoProfile` value object with detected stacks, languages, frameworks, and config paths
- [x] 6.9 Implement detector factory that runs all detectors and merges results

## 7. Static Analysis Layer

- [x] 7.1 Implement `Analyzers::Runner` base class with common command execution, output parsing, and error handling
- [x] 7.2 Implement `Analyzers::RubocopRunner` for Ruby projects with JSON output parsing
- [x] 7.3 Implement `Analyzers::BrakemanRunner` for Rails projects with JSON output parsing
- [x] 7.4 Implement `Analyzers::ReekRunner` for Ruby projects with JSON output parsing
- [x] 7.5 Implement `Analyzers::ESLintRunner` for JS/TS projects with JSON output parsing
- [x] 7.6 Implement `Analyzers::TypeScriptRunner` for TS projects with tsc --noEmit
- [x] 7.7 Implement `Analyzers::DartAnalyzerRunner` for Dart/Flutter projects
- [x] 7.8 Implement `Analyzers::GolangciLintRunner` for Go projects with JSON output parsing
- [x] 7.9 Implement `Analyzers::GoVetRunner` for Go projects
- [x] 7.10 Implement `Analyzers::Orchestrator` that selects and runs appropriate analyzers based on repo profile
- [x] 7.11 Implement `Models::AnalysisResult` value object unifying all analyzer output formats

## 8. Diff Processing

- [x] 8.1 Implement `Services::DiffExtractor` class that retrieves git diff between base and head branches
- [x] 8.2 Implement `Services::FileCategorizer` class that classifies files into source, test, config, generated, binary, vendor, lockfile, snapshot
- [x] 8.3 Implement `Services::DiffChunker` class that splits large diffs into processable chunks
- [x] 8.4 Implement `Services::DiffFilter` class that excludes binary, generated, lockfile, vendor, and snapshot files
- [x] 8.5 Implement `Models::DiffFile` value object with path, status, additions, deletions, patch content, and category
- [x] 8.6 Implement `Models::DiffChunk` value object with files, token_estimate, and priority score

## 9. AI Review Engine

- [x] 9.1 Implement `AI::Client` class that sends requests to DeepSeek API via Faraday with configurable timeout
- [x] 9.2 Implement `AI::RetryHandler` class with exponential backoff (1s, 2s, 4s) and max 3 retries
- [x] 9.3 Implement `AI::TokenBudget` class that estimates token counts and enforces context window limits
- [x] 9.4 Implement `AI::PromptBuilder` class that assembles layered prompts (System, Language, Repository, PR Context)
- [x] 9.5 Implement `AI::PromptBuilder` system prompt defining review philosophy, severity model, and JSON output schema
- [x] 9.6 Implement `AI::PromptBuilder` language prompts for each supported stack with framework-specific expertise
- [x] 9.7 Implement `AI::PromptBuilder` repository prompt from `.reviewbot.yml` rules
- [x] 9.8 Implement `AI::ResponseParser` class that validates and parses structured JSON from AI responses
- [x] 9.9 Implement `AI::ResponseParser` fallback for malformed JSON with regex extraction
- [x] 9.10 Implement `AI::ReviewCache` class that caches AI results by PR + commit SHA
- [x] 9.11 Implement `AI::ReviewEngine` facade that orchestrates prompt assembly, API call, retry, parsing, and caching
- [x] 9.12 Implement `AI::IncrementalReviewer` that re-reviews only changed files on subsequent PR updates

## 10. Language-Specific Reviewers

- [x] 10.1 Implement `Reviewers::Base` abstract base class with common interface (detect, analyze, review_prompt, review_focus)
- [x] 10.2 Implement `Reviewers::RubyReviewer` with Ruby-specific review heuristics and analyzer selection
- [x] 10.3 Implement `Reviewers::RailsReviewer` with Rails-specific review heuristics (N+1, transactions, callbacks, fat controllers)
- [x] 10.4 Implement `Reviewers::JavaScriptReviewer` with JS-specific heuristics (async bugs, callbacks, module patterns)
- [x] 10.5 Implement `Reviewers::TypeScriptReviewer` with TS-specific heuristics (type safety, strict mode, type narrowing)
- [x] 10.6 Implement `Reviewers::ReactReviewer` with React-specific heuristics (hooks rules, rerenders, state management)
- [x] 10.7 Implement `Reviewers::FlutterReviewer` with Flutter-specific heuristics (widget rebuilds, state management, memory)
- [x] 10.8 Implement `Reviewers::DartReviewer` with Dart-specific heuristics (null safety, async patterns)
- [x] 10.9 Implement `Reviewers::GoReviewer` with Go-specific heuristics (goroutines, context, error handling)
- [x] 10.10 Implement `Reviewers::ReviewerFactory` that selects the correct reviewer(s) based on repo profile

## 11. Review Pipeline

- [x] 11.1 Implement `Pipelines::Base` abstract pipeline class with phase sequencing
- [x] 11.2 Implement `Pipelines::RubyPipeline` orchestrating Ruby/Rails review phases
- [x] 11.3 Implement `Pipelines::NodePipeline` orchestrating JS/TS/React review phases
- [x] 11.4 Implement `Pipelines::FlutterPipeline` orchestrating Flutter/Dart review phases
- [x] 11.5 Implement `Pipelines::GoPipeline` orchestrating Go review phases
- [x] 11.6 Implement `Services::PipelineOrchestrator` that selects pipeline based on profile, runs phases, and aggregates results
- [x] 11.7 Implement progress event emitter for terminal UI updates during pipeline execution
- [x] 11.8 Implement `Services::ReviewContext` class that assembles all context for AI review
- [x] 11.9 Implement `Services::ReviewCoordinator` top-level service that ties together detection, checkout, analysis, AI, and storage

## 12. Report Formatting & Export

- [x] 12.1 Implement `Formatters::Markdown::Report` class that generates the full markdown report document
- [x] 12.2 Implement `Formatters::Markdown::SummarySection` for PR overview and risk level with severity counts table
- [x] 12.3 Implement `Formatters::Markdown::FindingsSection` grouping findings by severity with coded formatting
- [x] 12.4 Implement `Formatters::Markdown::FileBreakdownSection` grouping findings by file
- [x] 12.5 Implement `Formatters::Markdown::MissingTestsSection` listing source files without test coverage
- [x] 12.6 Implement `Formatters::Markdown::ArchitectureNotesSection` for AI architecture observations
- [x] 12.7 Implement `Formatters::Markdown::SecurityNotesSection` for security findings
- [x] 12.8 Implement `Formatters::Terminal::Display` class for terminal output with pastel colors and tty-table
- [x] 12.9 Implement `Formatters::Terminal::PRTable` for the PR listing table
- [x] 12.10 Implement `Formatters::Terminal::FindingsSummary` for review results in terminal
- [x] 12.11 Implement `Services::ReportExporter` that writes markdown to file and returns path

## 13. CLI Commands

- [x] 13.1 Implement `CLI::Base` Thor subclass with global options (verbose, config path)
- [x] 13.2 Implement `CLI::PRS` command class for `reviewbot prs` with PR listing and interactive selection
- [x] 13.3 Implement `CLI::Review` command class for `reviewbot review [PR_NUMBER]` with --all flag
- [x] 13.4 Implement `CLI::Publish` command class for `reviewbot publish PR_NUMBER`
- [x] 13.5 Implement `CLI::Export` command class for `reviewbot export PR_NUMBER`
- [x] 13.6 Implement `CLI::Cache` command class for `reviewbot cache:clear`
- [x] 13.7 Implement spinner integration in CLI commands showing progress for each phase
- [x] 13.8 Implement color-coded output in all CLI commands using pastel

## 14. Error Handling & Logging

- [x] 14.1 Implement `Utils::Logger` class with configurable log levels and structured format
- [x] 14.2 Implement `Utils::ErrorHandler` class with graceful degradation patterns
- [x] 14.3 Implement error handling for missing external tools (gh, rubocop, eslint, etc.)
- [x] 14.4 Implement error handling for network failures (GitHub API, DeepSeek API)
- [x] 14.5 Implement error handling for invalid configuration
- [x] 14.6 Implement user-friendly error messages for all common failure modes

## 15. Testing

- [x] 15.1 Write RSpec tests for `Config::Loader` and `Config::RepositoryConfig`
- [x] 15.2 Write RSpec tests for database models and cache repository classes
- [x] 15.3 Write RSpec tests for `GitHub::Client` with WebMock stubs
- [x] 15.4 Write RSpec tests for `GitHub::PRFetcher` with WebMock stubs
- [x] 15.5 Write RSpec tests for `Git::CLI` and branch management
- [x] 15.7 Write RSpec tests for static analyzer runners with mock output fixtures
- [x] 15.8 Write RSpec tests for `AI::Client` with WebMock stubs
- [x] 15.10 Write RSpec tests for `AI::PromptBuilder` layered prompt assembly
- [x] 15.12 Write RSpec tests for `Services::PipelineOrchestrator`
- [x] 15.14 Write RSpec tests for CLI command classes
- [x] 15.15 Write RSpec tests for `Services::DiffChunker` and file categorization
- [x] 15.16 Write RSpec tests for error handling and graceful degradation paths

## 16. Documentation & Polish

- [x] 16.1 Write README.md with description, prerequisites, installation, configuration, usage, and examples
- [x] 16.2 Add CLI help text descriptions for all commands and options
- [x] 16.3 Create `.env.example` with all configurable environment variables documented
- [x] 16.4 Create example `.reviewbot.yml` with all configuration options documented
- [x] 16.5 Write CHANGELOG.md or setup release documentation
- [ ] 16.6 Verify all commands work end-to-end with sample PR (requires GITHUB_TOKEN + DEEPSEEK_API_KEY)
- [x] 16.7 Add shell completion support documentation
