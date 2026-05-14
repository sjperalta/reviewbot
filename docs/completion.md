# Shell Completion

To enable shell completion for reviewbot commands, add one of the following to your shell configuration:

## Bash

```bash
# Add to ~/.bashrc or ~/.bash_profile
eval "$(reviewbot completion bash)"
```

## Zsh

```zsh
# Add to ~/.zshrc
eval "$(reviewbot completion zsh)"
```

## Fish

```fish
# Add to ~/.config/fish/config.fish
reviewbot completion fish | source
```

The completion system provides:
- Command name completion (prs, review, publish, export, cache:clear)
- Option flag completion (--verbose, --all, --base-branch, etc.)
- PR number suggestion context where applicable
