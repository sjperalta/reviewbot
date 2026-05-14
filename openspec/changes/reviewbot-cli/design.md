## Context

reviewbot is a greenfield Ruby CLI tool for automated AI-powered Pull Request review. The project targets teams using GitHub who need consistent, expert-level code review across multiple languages and frameworks. The tool must integrate with GitHub for PR access, DeepSeek for AI analysis, and language-specific static analyzers for pre-review context.

The project directory is `/Users/sergioperalta/Documents/Source/reviewbot` and will be structured as a standard Ruby gem with Thor CLI.

## Goals / Non-Goals

**Goals:**
- Feature-based architecture with small, focused classes following SOLID principles
- Thor-based CLI with polished terminal UX (colors, spinners, tables, interactive prompts)
- GitHub integration via Octokit and `gh` CLI for fetching PRs and publishing reviews
- Multi-language static analysis that runs before AI review to enrich context
- DeepSeek API client with retries, token budgeting, and structured JSON parsing
- Language-aware review pipelines for Ruby/Rails, JS/TS/React, Flutter/Dart, Go
- SQLite-backed caching and persistence layer
- Hierarchical configuration (.env for secrets, .reviewbot.yml for rules, CLI flags)
- Comprehensive RSpec test suite with WebMock and VCR
- Actionable markdown reports with severity-coded findings

**Non-Goals:**
- Not a CI/CD plugin or GitHub Action (though could be wrapped in one later)
- Not a general-purpose code review tool — focused on PR workflows
- Not a replacement for human review — augments it with AI-powered analysis
- Not a self-hosted web service — runs on developer machines and CI runners
- Not supporting GitLab, Bitbucket, or other providers initially

## Decisions

### 1. Feature-based over layer-based architecture
Feature-based packages (`cli/`, `github/`, `ai/`, `analyzers/`, `reviewers/`, `pipelines/`) rather than traditional `services/`, `models/`, `controllers/` layering. This keeps related code co-located, makes it easier to reason about feature boundaries, and simplifies extraction of features into separate gems if needed later.

### 2. Thor over OptionParser or Commander
Thor provides built-in subcommand support, option parsing, help generation, and class-based command organization. This maps naturally to the `reviewbot prs`, `reviewbot review`, `reviewbot publish` command structure. OptionParser would require more boilerplate for the same functionality.

### 3. Octokit + `gh` CLI over pure Octokit
Octokit handles API interactions (PR metadata, publishing comments). `gh` CLI handles authentication (already configured by the user) and Git operations (checkout, clone). This avoids duplicating GitHub auth handling and Git operations that `gh` already solves well.

### 4. SQLite over YAML/JSON file storage
SQLite provides querying, indexing, and relationship management that flat files don't. The `reviews`, `findings`, `cached_diffs` tables need relationship queries (e.g., "findings for a review") and deduplication. SQLite is available on all platforms including CI runners with no external server.

### 5. Concurrent Ruby for parallel review over sequential processing
When reviewing multiple PRs (`--all` flag) or analyzing multiple files within a PR, Concurrent Ruby's thread pool executor enables parallel static analysis runs. This significantly reduces total review time without the complexity of full external job queues.

### 6. Direct DeepSeek API over OpenAI-compatible abstraction layer
DeepSeek's API is OpenAI-compatible, so a thin Faraday-based client is sufficient. An abstraction layer over multiple AI providers adds complexity without current benefit. If multi-provider support is needed later, the AI client interface can be extracted.

### 7. Language-specific reviewer classes over a single monolithic reviewer
Each language gets its own reviewer class (`Reviewers::RubyReviewer`, `Reviewers::GoReviewer`, etc.) that knows the relevant analyzers, review heuristics, and best practices. A factory method selects the right reviewer based on repository detection. This keeps language-specific logic isolated and makes adding new languages straightforward.

### 8. Layered AI prompting strategy over single-shot prompts
System → Language → Repository → PR Context prompts are assembled incrementally. Each layer adds domain-specific expertise. This produces higher quality reviews than a single monolithic prompt and allows independent tuning of each layer.

### 9. Markdown file export over database-only storage
Findings are stored in SQLite for persistence, but also exported to markdown for sharing, archiving, and CI artifact use. Markdown renders well on GitHub and can be committed to PRs as review summaries.

### 10. `tty` ecosystem over custom terminal formatting
tty-prompt, tty-table, tty-spinner, and pastel provide battle-tested terminal UI components. Building custom equivalents would be wasteful and error-prone across terminal emulators.

## Risks / Trade-offs

- **Risk**: DeepSeek API latency or outages → Mitigation: Implement retries with exponential backoff, configurable timeouts, and graceful degradation (report what static analysis found even if AI review fails)
- **Risk**: Static analysis tools not installed on reviewer machine → Mitigation: Graceful skip with warning, run what's available, document prerequisites in setup
- **Risk**: Large PR diffs exceeding token limits → Mitigation: Chunked diff processing with token budgeting, skip binary/generated/lockfile files, prioritize changed files by impact score
- **Risk**: False positives from AI review → Mitigation: Risk scoring with confidence levels, clear severity model, human-in-the-loop for publish commands
- **Risk**: GitHub API rate limiting → Mitigation: Caching with SQLite, conditional requests with ETags, pagination handling
- **Trade-off**: Language-specific reviewers vs generic reviewer — more initial code but higher quality reviews per language
- **Trade-off**: CLI-only vs web dashboard — simpler initial delivery, but no persistent review history beyond markdown exports
