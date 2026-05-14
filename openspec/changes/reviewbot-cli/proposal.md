## Why

Manual code review is slow, inconsistent, and doesn't scale across teams and repositories. Engineering teams waste hours on superficial review issues while missing deep architectural problems, security vulnerabilities, and framework-specific anti-patterns. An AI-powered PR reviewer that is language-aware, framework-aware, and context-aware can catch issues faster, enforce team standards consistently, and free human reviewers to focus on higher-level design decisions.

## What Changes

- Build `reviewbot`, a CLI tool that automatically reviews GitHub Pull Requests using AI
- Implement multi-language support: Ruby/Rails, JavaScript/TypeScript/React, Flutter/Dart, Go
- Integrate static analysis tools as pre-AI context (Rubocop, ESLint, golangci-lint, dart analyze, etc.)
- Connect to DeepSeek API for AI-generated code review findings with structured JSON output
- Implement GitHub integration via Octokit and GitHub CLI for PR fetching and comment publishing
- Auto-detect repository language and framework from project files
- Provide polished terminal UX with progress spinners, color-coded severity, and interactive tables
- Support SQLite-based caching, review persistence, and incremental analysis
- Implement configurable `.reviewbot.yml` for per-repository rules and conventions
- Generate actionable markdown reports and optional auto-publish to GitHub

## Capabilities

### New Capabilities

- `cli-interface`: Thor-based CLI with commands for listing PRs, reviewing, publishing, exporting, and cache management with interactive prompts and color-coded output
- `pr-management`: Fetch assigned PRs via `gh` CLI, select interactively or by number, checkout locally, and prepare for review
- `github-integration`: Octokit-based client for fetching PR metadata (title, description, labels, files, commits) and publishing review comments as pull request reviews
- `repo-detection`: Language and framework auto-detection engine that reads project files (Gemfile, package.json, tsconfig.json, pubspec.yaml, go.mod, etc.) to build a repository profile
- `static-analysis`: Multi-language static analysis runner that executes Rubocop, Brakeman, Reek, ESLint, TypeScript compiler, dart analyze, golangci-lint, etc. and parses results into structured findings
- `ai-review`: DeepSeek API client with retries, timeout handling, token budgeting, chunked diff processing, and structured JSON response parsing for code review findings
- `review-pipeline`: Orchestration layer that sequences repository detection, diff extraction, static analysis, context assembly, AI review, and result formatting for each supported language
- `configuration`: Hierarchical configuration system supporting `.env` for secrets, `.reviewbot.yml` for repository rules, and CLI flags with sensible defaults
- `cache-persistence`: SQLite-backed persistence for repositories, pull requests, reviews, findings, cached diffs, and review runs
- `report-export`: Markdown report generator with severity-coded findings, file-by-file breakdown, summary statistics, and architecture/security notes sections

### Modified Capabilities

<!-- No existing capabilities to modify -->

## Impact

- New Ruby gem: `reviewbot` with dependencies on Thor, Octokit, Faraday, Concurrent Ruby, SQLite3, tty-prompt, tty-table, tty-spinner, pastel, and dotenv
- External tool dependencies: GitHub CLI (`gh`), language-specific analyzers (Rubocop, ESLint, golangci-lint, etc.)
- External API dependency: DeepSeek API key required in environment
- No existing code or systems affected - this is a greenfield project
