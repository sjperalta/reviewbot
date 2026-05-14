# Changelog

## 0.1.0 (Unreleased)

- Initial release of reviewbot
- CLI commands: `prs`, `review`, `publish`, `export`, `cache:clear`
- GitHub integration via Octokit and `gh` CLI
- Multi-language support: Ruby, Rails, JavaScript, TypeScript, React, Flutter, Dart, Go
- Static analysis integration: Rubocop, Brakeman, Reek, ESLint, tsc, dart analyze, golangci-lint, go vet
- AI review engine via DeepSeek API with retry, token budgeting, and caching
- Language-specific reviewers with framework-aware heuristics
- SQLite persistence for reviews, findings, and caching
- Markdown report generation with severity-coded findings
- Polished terminal UI with colors, spinners, and tables
- Configurable `.reviewbot.yml` per-repository configuration
