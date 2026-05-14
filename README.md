# reviewbot

What it does: Fetches your assigned GitHub PRs, checks out branches locally, auto-detects the language/framework, runs static analysis (Rubocop, ESLint, golangci-lint, etc.), sends a layered context to DeepSeek for AI review, and produces severity-coded reports with actionable findings.

## Prerequisites

- Ruby 3.2+
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated
- Language-specific analyzers (optional):
  - Ruby/Rails: `rubocop`, `brakeman`, `reek`
  - JS/TS: `eslint`, `typescript`
  - Flutter/Dart: `dart`
  - Go: `golangci-lint`

## Installation

```bash
git clone <repo>
cd reviewbot
bundle install
```

## macOS Setup

After installation, make the `reviewbot` command available on your PATH:

### Option 1 — Symlink into PATH (recommended)

```bash
ln -sf "$(pwd)/exe/reviewbot" /usr/local/bin/reviewbot
```

### Option 2 — Add to PATH

Add the following to `~/.zshrc`:

```bash
export PATH="$PATH:/path/to/reviewbot/exe"
```

Then reload: `source ~/.zshrc`

### Option 3 — Bundle exec alias

```bash
alias reviewbot='bundle exec ruby exe/reviewbot'
```

Add to `~/.zshrc` to make it permanent.

## Configuration

Copy `.env.example` to `.env` and configure:

```env
GITHUB_TOKEN=ghp_...          # Required: GitHub personal access token
DEEPSEEK_API_KEY=sk-...       # Optional: enables AI-powered review
DEFAULT_BASE_BRANCH=main      # Default branch for diff comparison
```

### Environment file precedence

reviewbot merges variables from every `.env` file it finds, in this order (later files override earlier ones for the same key):

1. `~/.reviewbot/.env`
2. `.env` next to the installed reviewbot gem (when developing from a clone, the repo root)
3. `.env` in the current working directory

Values already set in your shell (`export VAR=...`) are not overwritten by the merged files. Put shared secrets in `~/.reviewbot/.env` and project-specific overrides in the repo you run commands from.

### Per-Repository Configuration

Create `.reviewbot.yml` in the repository root:

```yaml
stack:
  - rails
  - react
  - typescript

rules:
  require_specs: true
  avoid_fat_controllers: true

ignore:
  - db/schema.rb
  - yarn.lock
  - snapshots/
```

## Usage

```bash
# List assigned PRs
reviewbot prs

# Review a specific PR
reviewbot review 123

# Review all assigned PRs
reviewbot review --all

# Publish review to GitHub
reviewbot publish 123

# Export report as markdown
reviewbot export 123

# Clear cache
reviewbot cache:clear
```

## Architecture

The project follows a feature-based architecture:

- `cli/` — Thor CLI commands
- `github/` — Octokit and GitHub CLI integration
- `git/` — Git operations
- `ai/` — DeepSeek API client and review engine
- `analyzers/` — Static analysis tool runners
- `reviewers/` — Language-specific review heuristics
- `pipelines/` — Language-specific review pipelines
- `services/` — Business logic and orchestration
- `formatters/` — Markdown and terminal output
- `cache/` — SQLite persistence layer
- `models/` — Value objects
- `config/` — Configuration system
- `utils/` — Logging and error handling

## Supported Languages

| Language/Framework | Detection | Analyzers | Review Focus |
|---|---|---|---|
| Ruby | Gemfile | Rubocop, Reek | Error handling, idioms, performance |
| Rails | Gemfile + rails | Rubocop, Brakeman, Reek | N+1, transactions, callbacks, security |
| JavaScript | package.json | ESLint | Async, memory, modules |
| TypeScript | tsconfig.json | ESLint, tsc | Type safety, strict mode |
| React | react dep | ESLint | Hooks, rerenders, state |
| Flutter | pubspec.yaml | dart analyze | Widget rebuilds, state, memory |
| Dart | .dart files | dart analyze | Null safety, async |
| Go | go.mod | golangci-lint, go vet | Goroutines, context, errors |

## Development

```bash
bundle exec rspec        # Run tests
bundle exec standard     # Lint with Standard
```

## License

MIT
