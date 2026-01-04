# Tool Chest

![GitHub License](https://img.shields.io/github/license/AndrewWeinmann/tool-chest)

Personal development tools, configs, templates, and automation I use across machines and projects:

- Dev container starters
- AI coding prompts and assistant skills
- Small, focused scripts

## Structure

### `ai`

Reusable prompts, instructions, and skills for coding assistants.

### `devcontainers`

Starter dev container setups for common stacks.
Each directory should be usable as a copy-paste baseline.

### `scripts`

Small, focused scripts that remove friction.
If it needs a framework, it does not belong here.

## What goes here

Includes things that:

- Are reused across machines or projects
- Have already proven useful more than once
- Reduce setup time or mental overhead
- Are small enough to understand at a glance

Examples:

- Dev container baselines
- Refined AI prompts I trust
- Bootstrap or cleanup scripts
- Glue code that saves minutes repeatedly

## What does NOT go here

- Project-specific configuration
- One-off throwaway scripts
- Half-finished experiments
- Large tools that deserve their own repository
- Anything that requires heavy documentation to explain

If something might belong here someday - put it in the project repo first. Promote it later.

## Naming rules

Consistency matters.

- Scripts: **verb-noun** (`cleanup-branches.sh`)
- Dev containers: **stack-based** (`node`, `python`, `go`)
- AI prompts: **task-oriented** (`code-review.md`, not `review1.md`)
- Avoid junk folders (`misc`, `old`, `temp`)
