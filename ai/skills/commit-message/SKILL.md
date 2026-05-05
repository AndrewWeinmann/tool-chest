---
name: commit-message
description: Write clear, useful commit messages for code changes. Use this skill whenever the user asks you to write a commit message, draft a PR description, summarize a code change for version control, or when you've just completed a coding task and need to commit it. Also trigger when the user says "commit this," "write a commit msg," "what should the commit message be," or asks you to describe changes for a pull request or merge request.
---

# Writing Useful Commit Messages

A good commit message helps reviewers approach a change, communicates impact to teammates and downstream users, aids future bug investigations, and feeds development tools (auto-closing issues, generating release notes). The audience ranges from the reviewer reading the diff right now to a developer doing `git blame` years from now.

## Core philosophy

**Say what changed and why, not how.** The diff already shows the how. The commit message's job is to provide the context the diff can't: motivation, impact, constraints, and decisions.

**Scale the message to the change.** A one-line typo fix needs a one-line message. A complex refactor or security fix needs structured paragraphs. Most commits fall somewhere in between — a clear title plus a short paragraph of context. Never pad a simple change with ceremony it doesn't need.

**Put the most important information first.** Readers should be able to stop reading as soon as they have what they need (the "inverted pyramid" from journalism). Lead with impact, then motivation, then details.

## Structure

### The title (first line)

The title is the single most important part — it's what shows up in `git log --oneline`, GitHub's commit list, and blame annotations.

- Describe the **effect** of the change, not the implementation mechanism.
  - Bad: "Add a mutex to guard the database handle"
  - Good: "Prevent database corruption during simultaneous sign-ups"
- Keep it under ~72 characters so it displays well in terminal UIs.
- Use imperative mood ("Add," "Fix," "Prevent," "Remove") — this matches git's own conventions (`Merge branch...`, `Revert "..."`).
- Don't end with a period.
### The body

Separate the body from the title with a blank line. Include only the sections that are relevant — most commits need only one or two of these, and some need none at all.

**Motivation / why:** Explain why this change is being made. What problem does it solve? What goal does it serve? Without this, future readers see *what* happened but can never recover *why*. This is the single most valuable thing to include beyond the title.

**Impact on users or clients:** If the change affects behavior that people outside the codebase will notice, say so. What's different for them? Do they need to do anything?

**Breaking changes:** Call these out explicitly with a recognizable label (e.g., a `Breaking change` heading or a `BREAKING:` prefix). Explain what breaks and how to migrate.

**Alternatives considered:** If you tried an obvious approach and it didn't work, briefly explain why so future readers don't waste time rediscovering the same dead ends. If the explanation is about a specific line of code, prefer a code comment instead — but if it's a design-level decision, the commit message is the right place.

**New dependencies:** Flag any new third-party dependencies and briefly justify why they're worth the maintenance cost.

**Cross-references:** Mention related issues (`Fixes #1234`), pull requests, or commit hashes. Auto-closing keywords (`Fixes`, `Resolves`, `Closes`) are useful for issue trackers. When referencing a bug or ticket with a complex history, summarize the relevant details rather than forcing the reader to go read the entire thread.

**Testing notes:** If the change can't be fully exercised by automated tests, explain how to test it manually or what scenarios remain untested. Disclose testing limitations honestly — this helps reviewers assess risk.

**What you learned:** If you discovered something non-obvious while implementing the change (an unexpected API behavior, a subtle language gotcha), capture it while it's fresh. This is genuinely valuable to future readers.

**Searchable artifacts:** If the change relates to a specific error message, include the error text so `git log --grep` can find it later.

**Headings:** For longer messages, use markdown-style headings (`## Background`, `## Motivation`, `## Alternatives`) to let readers scan and jump to what matters to them.

## What to leave out

- **What the diff already shows.** Don't list the files you changed, the functions you called, or whether the change is large or small. The reader will see this in the code.
- **Information that belongs in the code itself.** Critical invariants, non-obvious constraints, and maintenance warnings should be code comments or assertions, not buried in a commit message that future maintainers may never find.
- **Ephemeral discussion.** Questions for reviewers, TODOs for yourself, `@mentions` asking someone to look at something — these belong in PR comments, not in the permanent commit history.
- **Transient links.** Preview URLs, CI build links, or other artifacts that expire in weeks become dead noise in the history. Let tooling surface these during review instead.
## Tone

Be direct and clear. Rants, war stories, and humor are fine — but put them at the end, clearly separated, after the essential information. Someone chasing a production bug at 2 AM should find what they need in the first few lines.

## Generating a commit message

When writing a commit message for a set of changes:

1. Look at the actual diff or the work just completed. Understand what changed at a semantic level — not file-by-file, but what the overall effect is.
2. Write a title that captures the effect in imperative mood.
3. Decide which body sections (if any) the change warrants. A one-line fix needs no body. A multi-file refactor probably needs motivation and maybe alternatives considered. A new feature probably needs impact and maybe testing notes.
4. Write only the sections that earn their space. Don't include empty headings or boilerplate.
5. Cross-reference any related issues or commits if you know about them.
6. Review: does the message explain what a reader can't get from the diff alone? If not, add it. Does it repeat what the diff already says? If so, cut it.
