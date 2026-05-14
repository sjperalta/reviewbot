## ADDED Requirements

### Requirement: System fetches assigned PRs via GitHub CLI
The system SHALL use `gh pr list` to discover open PRs where the current user is requested as reviewer.

#### Scenario: Fetch assigned PRs
- **WHEN** the system queries for assigned PRs
- **THEN** it executes `gh pr list --search "review-requested:@me is:open" --json number,title,author,repository,url`
- **THEN** it parses the JSON output into structured PR objects

### Requirement: System supports interactive PR selection
The system SHALL allow the user to select a PR from the list using an interactive tty-prompt menu.

#### Scenario: Interactive selection
- **WHEN** the PR list has multiple entries
- **THEN** the system displays an interactive selection menu with PR numbers and titles
- **THEN** the selected PR is used for subsequent review operations

### Requirement: System checks out PRs locally
The system SHALL use `gh pr checkout <number>` to fetch the PR branch into a local working directory.

#### Scenario: Checkout a PR
- **WHEN** user selects a PR for review
- **THEN** the system runs `gh pr checkout <number>` in the repository directory
- **THEN** the system verifies the checkout was successful
- **THEN** the system records the current branch for later cleanup

### Requirement: System restores the original branch after review
The system SHALL return to the previously active branch after completing a review.

#### Scenario: Restore branch after review
- **WHEN** the review completes
- **THEN** the system runs `git checkout <original-branch>`
- **THEN** the system confirms the branch was restored

### Requirement: System handles repositories not yet cloned locally
The system SHALL clone repositories that are not present in the local workspace.

#### Scenario: Clone missing repository
- **WHEN** the repository is not found locally
- **THEN** the system runs `gh repo clone <owner>/<repo>` to a configured workspace directory
- **THEN** the system proceeds with PR checkout
