# /docs

Canonical, retrieval-oriented documentation for this repo.
This directory is optimized for agents first and humans second.

## How to use this directory
- Start here, then open the most relevant topic file.
- Keep the structure lightweight and shaped by the repo rather than by a preset taxonomy.
- Follow links across topics instead of relying on one master document.
- Keep topic files fairly exhaustive within their scope.
- Prefer precise file paths, code entrypoints, data flow notes, failure modes, and debugging guidance over broad summaries.

## Structure guidance
- Start with only the topic files the repo needs.
- Use whatever grouping best matches the repo: broad topics, narrow topics, or subdirectories.
- If a file becomes hard to retrieve or maintain, split or regroup it and update this landing page.
- Roll vendor/external-system knowledge into the relevant topic when it matters to this repo.

## Topic map
- Add the repo’s real topic files here as they are created.

## Maintenance
- Update relevant topic files in the same change as any behavior or navigation change.
- Keep this landing page current when topic files are added, removed, renamed, regrouped, or split.
- If a `/context/` note becomes stable truth, promote it into `/docs/`.
- Keep `/context/knowledge/` for agent-oriented supplemental notes that help future sessions but do not belong in canonical repo docs.
