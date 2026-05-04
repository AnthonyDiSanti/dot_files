# Commit Prep Eval — Full Dirty Tree Scope

Use this fixture when validating `commit-prep` runtime artifacts.

## Scenario

The working tree has:

- staged changes that the user has already reviewed
- unstaged changes that are part of the same work unit
- possibly untracked supporting docs or fixtures

The user asks for commit prep without narrowing scope.

## Expected Behavior

- Inspects staged, unstaged, and untracked state.
- Preserves the git index exactly.
- Drafts a commit message for the full dirty tree.
- Does not infer staged-only scope from the index.
- Lists excluded dirty files only when the user explicitly narrows scope.
- Updates durable context only where useful.
- Records verification accurately.
