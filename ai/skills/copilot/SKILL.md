---
name: copilot
description: Use when the user asks to run GitHub Copilot CLI or references GitHub Copilot for code analysis, refactoring, or automated editing
---

# GitHub Copilot CLI Skill Guide

## Running a Task

1. Ask the user (via `AskUserQuestion`) which model to run (e.g., `claude-sonnet-4.5`, `gpt-5.2`, `gpt-5.1-codex`) in a single prompt.
2. Select the appropriate mode and permissions for the task:
   - Interactive mode (`-i`) for ongoing work
   - Non-interactive mode (`-p`) for one-off tasks (requires `--allow-all-tools`)
3. Assemble the command with the appropriate options:
   - `--model <MODEL>` (claude-sonnet-4.5, gpt-5.2, gpt-5.1-codex, etc.)
   - `--allow-all-tools` (for non-interactive mode or to skip tool confirmations)
   - `--add-dir <directory>` (to grant access to specific directories)
   - `--allow-all-paths` (to disable path verification entirely)
   - `-s, --silent` (to output only agent response, useful for scripting)
4. When continuing a previous session, use `copilot --continue` or `copilot --resume [sessionId]`.
5. Run the command and summarize the outcome for the user.
6. **After Copilot completes**, inform the user: "You can resume this session at any time by saying 'copilot continue' or asking me to continue with additional analysis or changes."

### Quick Reference

| Use case | Mode | Key flags |
| --- | --- | --- |
| Interactive coding session | Interactive | `copilot -i "prompt" --model <model>` |
| One-off task (automated) | Non-interactive | `copilot -p "prompt" --model <model> --allow-all-tools` |
| Silent output (scripting) | Non-interactive | `copilot -p "prompt" --allow-all-tools --silent` |
| Resume most recent session | Continue | `copilot --continue` |
| Resume specific session | Resume | `copilot --resume [sessionId]` |
| Grant directory access | Either | `--add-dir /path/to/dir` |
| Allow all file paths | Either | `--allow-all-paths` |
| Share session to file | Non-interactive | `--share [path]` or `--share-gist` |

### Common Model Options

- `claude-sonnet-4.5` - Latest Claude Sonnet model
- `claude-opus-4.5` - Latest Claude Opus model
- `gemini-3-pro-preview` - Google Gemini 3 Pro Preview model
- `gpt-5.2` - GPT-5.2 model
- `gpt-5.1-codex` - Codex-specialized GPT model
- `gpt-5.1-codex-max` - Maximum capability Codex model
- `gpt-5-mini` - Faster, lightweight model

### Permission and Access Control

- `--allow-all-tools` - Required for non-interactive mode; allows all tools without confirmation
- `--allow-tool [tools...]` - Explicitly allow specific tools (e.g., `--allow-tool 'shell(git:*)' --allow-tool 'write'`)
- `--deny-tool [tools...]` - Explicitly deny specific tools (e.g., `--deny-tool 'shell(git push)'`)
- `--add-dir <directory>` - Add directory to allowed list (can be used multiple times)
- `--allow-all-paths` - Disable path verification (use with caution)
- `--allow-url [urls...]` - Allow access to specific URLs or domains
- `--allow-all-urls` - Allow all URLs without confirmation

### Example Commands

```bash
# Interactive session with Claude
copilot -i "Fix the bug in main.js" --model claude-sonnet-4.5

# Non-interactive task with auto-approval
copilot -p "Refactor auth.ts to use async/await" --model gpt-5.1-codex --allow-all-tools

# Resume most recent session
copilot --continue

# Resume with session picker
copilot --resume

# Grant access to specific directories
copilot -i "Analyze project structure" --add-dir ~/workspace --add-dir /tmp

# Silent mode for scripting
copilot -p "Generate test file for utils.js" --allow-all-tools --silent

# Share session to file after completion
copilot -p "Add error handling" --allow-all-tools --share ./session-log.md
```

## Following Up

- After every `copilot` command, immediately use `AskUserQuestion` to confirm next steps, collect clarifications, or decide whether to continue with `copilot --continue`.
- When resuming, use `copilot --continue` for the most recent session or `copilot --resume` to pick from previous sessions.
- The resumed session automatically uses the same model and settings from the original session.
- Restate the chosen model and mode when proposing follow-up actions.

## Error Handling

- Stop and report failures whenever a `copilot` command exits non-zero; request direction before retrying.
- Before using high-impact flags (`--allow-all-tools`, `--allow-all-paths`), ask the user for permission using AskUserQuestion unless it was already given.
- When output includes warnings or partial results, summarize them and ask how to adjust using `AskUserQuestion`.
- If `copilot` is not installed, guide the user to install it from <https://docs.github.com/en/copilot/using-github-copilot/using-github-copilot-in-the-command-line>

## Best Practices

1. **Model Selection**: Choose the appropriate model based on task complexity (codex models for code-heavy tasks, claude for analysis)
2. **Permission Management**: Use `--add-dir` to grant specific access instead of `--allow-all-paths` when possible
3. **Tool Permissions**: In interactive mode, let the user approve tools individually; use `--allow-all-tools` only for non-interactive automation
4. **Session Continuity**: Leverage `--continue` and `--resume` for multi-step workflows instead of starting fresh each time
5. **Silent Mode**: Use `--silent` when scripting to get clean output without stats

## Additional Options

- `--log-level <level>` - Set logging verbosity (none, error, warning, info, debug, all)
- `--stream <mode>` - Enable or disable streaming (on/off)
- `--no-custom-instructions` - Disable loading custom instructions from AGENTS.md
- `--agent <agent>` - Specify a custom agent (only in prompt mode)
- `--available-tools [tools...]` - Limit available tools to specific set
- `--disable-parallel-tools-execution` - Execute tools sequentially instead of in parallel
