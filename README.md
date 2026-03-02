# SuperNovae Registry

> **The open-source package registry for AI workflows, schemas, skills, and agents.**

[![License: MIT](https://img.shields.io/badge/License-MIT-10b981.svg)](LICENSE)
[![Version: v2](https://img.shields.io/badge/Version-v2-6366f1.svg)](#registry-architecture)
[![Packages: 46](https://img.shields.io/badge/Packages-46-f59e0b.svg)](#packages)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8b5cf6.svg)](CONTRIBUTING.md)

---

## Table of Contents

- [Overview](#overview)
- [The SuperNovae Ecosystem](#the-supernovae-ecosystem)
- [Quick Start](#quick-start)
- [Registry Architecture](#registry-architecture)
- [Packages](#packages)
- [Package Format](#package-format)
- [Publishing Packages](#publishing-packages)
- [CLI Reference](#cli-reference)
- [Contributing](#contributing)
- [Related Projects](#related-projects)
- [License](#license)

---

## Overview

SuperNovae Registry is a **git-based package registry** for distributing AI development assets. It provides reusable workflows, schemas, skills, prompts, jobs, and agents that integrate with:

- **[Nika](https://github.com/supernovae-st/nika)** — Semantic YAML workflow engine
- **[NovaNet](https://github.com/supernovae-st/novanet)** — Knowledge graph for localization
- **[Claude Code](https://claude.ai/code)** — AI assistant
- **[Cursor](https://cursor.sh)** — AI-powered IDE

```
+-----------------------------------------------------------------------------+
|  SUPERNOVAE REGISTRY v2                                                      |
+-----------------------------------------------------------------------------+
|                                                                              |
|  Package Types (6)                                                           |
|  +-- @workflows/     -> Nika YAML DAG workflows (.nika.yaml)                 |
|  +-- @schemas/       -> NovaNet node/arc classes                             |
|  +-- @skills/        -> Skill definitions for Claude/Cursor                  |
|  +-- @prompts/       -> Prompt templates                                     |
|  +-- @jobs/          -> Scheduled/triggered jobs                             |
|  +-- @agents/        -> Agent configurations                                 |
|                                                                              |
|  Alternate Scopes (aliases)                                                  |
|  +-- @nika/          -> alias for @workflows/                                |
|  +-- @novanet/       -> alias for @schemas/                                  |
|  +-- @shared/        -> alias for @skills/ (cross-project)                   |
|                                                                              |
+-----------------------------------------------------------------------------+
```

---

## The SuperNovae Ecosystem

### Mascots and Hierarchy

```
                            NIKA (Papillon)
                                 Runtime
                      Orchestrates the 5 semantic verbs
                                    |
        +---------------+-----------+-----------+---------------+
        |               |           |           |               |
        v               v           v           v               v
     infer:          exec:       fetch:     invoke:        agent:
      LLM           Shell        HTTP         MCP       (Space Chicken)
                                                              |
                                                        spawn_agent
                                                              |
                                                  +-----------+-----------+
                                                  v           v           v
                                            (Subagents - Poussins)
```

| Mascot | Role | What it does |
|--------|------|--------------|
| **Nika** | **Runtime** | Executes YAML workflows, runs chat UI, launches agents |
| **Agent** | **One verb** | Multi-turn agentic loop with MCP tools, spawns subagents |
| **Subagent** | **Spawned** | Executes subtask, returns result to parent, depth-limited |

> **Important:** Nika is NOT an agent. Nika is the runtime that orchestrates agents.

### How Packages Flow

```
+-----------------------------------------------------------------------------+
|  PACKAGE FLOW                                                                |
+-----------------------------------------------------------------------------+
|                                                                              |
|  1. Author publishes                                                         |
|  +-------------------+                                                       |
|  | packages/@nika/   |                                                       |
|  |   generate-page/  |                                                       |
|  |     index.json    | <-- Version metadata                                  |
|  |     v1.0.0.tar.gz | <-- Package tarball (GitHub Release)                  |
|  +-------------------+                                                       |
|            |                                                                 |
|            v                                                                 |
|  2. User installs                                                            |
|  +-------------------+     +-------------------+     +-------------------+   |
|  |   spn add ...     | --> |  Index Client     | --> |  Downloader       |   |
|  |                   |     |  (fetch metadata) |     |  (fetch tarball)  |   |
|  +-------------------+     +-------------------+     +-------------------+   |
|            |                                                                 |
|            v                                                                 |
|  3. Package installed                                                        |
|  +-------------------+                                                       |
|  | ~/.spn/cache/     |                                                       |
|  |   workflows/      |                                                       |
|  |     generate-page/| <-- Ready to use                                      |
|  +-------------------+                                                       |
|                                                                              |
+-----------------------------------------------------------------------------+
```

---

## Quick Start

### Install the CLI

```bash
# Via Homebrew (recommended)
brew tap supernovae-st/tap
brew install supernovae-st/tap/spn

# Via Cargo
cargo install spn

# Verify installation
spn --version
spn doctor
```

### Install Packages

```bash
# Install a workflow package
spn add @nika/generate-page

# Install a schema package
spn add @novanet/core-schema

# Install with specific version
spn add @nika/generate-page@1.0.0

# Install all dependencies from manifest
spn install
```

### Use in Your Project

Create a `spn.yaml` manifest in your project root:

```yaml
# spn.yaml
name: my-project
version: 1.0.0

# Owned packages (from registry)
workflows:
  - "@nika/generate-page@^1.0.0"
  - "@nika/seo-audit@^2.0.0"

schemas:
  - "@novanet/core-schema@^0.14.0"

# Interop packages (proxied)
skills:
  - "brainstorming"        # -> skills.sh
  - "superpowers/tdd"      # -> skills.sh

mcp:
  - "neo4j"                # -> npm @neo4j/mcp-server-neo4j
  - "perplexity"           # -> npm perplexity-mcp
```

Then run:

```bash
spn install
```

---

## Registry Architecture

### Sparse Index Pattern

The registry uses a **sparse index** pattern (inspired by Cargo) for efficient package resolution:

```
supernovae-registry/
+-- packages/
|   +-- @workflows/
|   |   +-- dev-productivity/
|   |   |   +-- code-review/
|   |   |       +-- index.json      # Version metadata
|   |   |       +-- 1.0.0.tar.gz    # (or GitHub Release)
|   |   +-- fun/
|   |       +-- weather-outfit/
|   |           +-- index.json
|   +-- @schemas/
|   |   +-- novanet/
|   |       +-- core-schema/
|   |           +-- index.json
|   +-- @skills/
|   +-- @prompts/
|   +-- @jobs/
|   +-- @agents/
+-- index.json                      # Root index with all packages
+-- registry.yaml                   # Registry configuration
```

### index.json Format

Each package has an `index.json` with version metadata:

```json
{
  "name": "@nika/generate-page",
  "versions": {
    "1.0.0": {
      "version": "1.0.0",
      "cksum": "sha256:abc123...",
      "yanked": false,
      "published": "2026-02-01T00:00:00Z",
      "deps": []
    },
    "1.1.0": {
      "version": "1.1.0",
      "cksum": "sha256:def456...",
      "yanked": false,
      "published": "2026-02-15T00:00:00Z",
      "deps": []
    }
  },
  "latest": "1.1.0"
}
```

### Package Resolution

1. **Client requests** `@nika/generate-page@^1.0.0`
2. **Index lookup**: Fetch `packages/@workflows/nika/generate-page/index.json`
3. **Version resolve**: Find latest compatible version (1.1.0 satisfies ^1.0.0)
4. **Download**: Fetch tarball from GitHub Release or direct URL
5. **Verify**: Check SHA256 checksum
6. **Install**: Extract to `~/.spn/cache/workflows/generate-page/1.1.0/`

---

## Packages

### Package Statistics

| Scope | Count | Description |
|-------|-------|-------------|
| `@workflows/` | 31 | Ready-to-use workflow templates |
| `@schemas/` | 2 | NovaNet graph schemas |
| `@skills/` | 10 | Cross-project development skills |
| `@prompts/` | 2 | Prompt templates |
| `@jobs/` | 1 | Scheduled jobs |
| **Total** | **46** | All packages |

### @nika/ — Workflow Engine Skills

Skills for authoring and debugging Nika YAML workflows.

| Package | Description | Version |
|---------|-------------|---------|
| `nika-run` | Run workflows with validation | 1.0.0 |
| `nika-debug` | Debug with traces and logging | 1.0.0 |
| `nika-spec` | Workflow specification reference | 1.0.0 |
| `nika-yaml` | YAML authoring guide | 1.0.0 |
| `nika-binding` | Data binding syntax (`use:`, `{{}}`) | 1.0.0 |
| `nika-arch` | Architecture diagrams | 1.0.0 |
| `nika-diagnose` | Troubleshooting checklist | 1.0.0 |
| `workflow-validate` | Schema validation | 1.0.0 |

### @novanet/ — Knowledge Graph Skills

Skills for NovaNet schema design and graph operations.

| Package | Description | Version |
|---------|-------------|---------|
| `schema-validate` | Schema validation patterns | 1.0.0 |
| `novanet-yaml` | YAML schema authoring | 1.0.0 |

### @shared/ — Development Skills

Cross-project skills for code quality and productivity.

| Package | Description | Version |
|---------|-------------|---------|
| `brainstorming` | Socratic ideation workflow | 1.0.0 |
| `test-driven-development` | TDD methodology | 1.0.0 |
| `systematic-debugging` | 4-phase debugging | 1.0.0 |
| `code-review` | Automated code review | 1.0.0 |
| `codebase-audit` | Dead code detection | 1.0.0 |
| `security-audit` | Vulnerability scanning | 1.0.0 |
| `token-audit` | API token management | 1.0.0 |
| `workspace-nav` | Project navigation | 1.0.0 |
| `release` | Release automation | 1.0.0 |
| `adr` | Architecture Decision Records | 1.0.0 |

### @workflows/ — Ready-to-Use Templates

Pre-built Nika workflows organized by category:

#### Dev Productivity (8)

| Workflow | Description | Pattern |
|----------|-------------|---------|
| `pr-description` | Generate PR description from diff | Linear DAG |
| `changelog-generator` | Generate changelog from commits | Linear DAG |
| `readme-generator` | Generate README from codebase | Fan-out |
| `code-review` | AI-powered code review | Parallel |
| `api-docs-generator` | Generate OpenAPI docs | Linear DAG |
| `test-generator` | Generate unit tests | Fan-out |
| `refactor-suggestions` | Suggest refactoring | Agent loop |
| `dependency-audit` | Audit dependencies | Parallel |

#### Content Creation (6)

| Workflow | Description | Pattern |
|----------|-------------|---------|
| `blog-post` | Generate blog posts | Linear |
| `social-media-pack` | Multi-platform content | Fan-out |
| `landing-page-copy` | Marketing copy | Parallel |
| `email-template` | Email generation | Linear |
| `documentation` | Technical docs | Agent |
| `translation` | Multi-language content | Fan-out |

#### Research & Analysis (5)

| Workflow | Description | Pattern |
|----------|-------------|---------|
| `web-research` | Web research aggregation | Agent |
| `competitor-analysis` | Competitive intelligence | Parallel |
| `paper-summarizer` | Academic paper summary | Linear |
| `trend-analysis` | Market trends | Parallel |
| `sentiment-analysis` | Text sentiment | Linear |

#### Data Processing (4)

| Workflow | Description | Pattern |
|----------|-------------|---------|
| `json-transformer` | JSON transformation | Linear |
| `csv-analyzer` | CSV analysis | Linear |
| `api-aggregator` | Multi-API aggregation | Parallel |
| `data-validator` | Schema validation | Linear |

#### Fun & Entertainment (8)

| Workflow | Description | Pattern |
|----------|-------------|---------|
| `weather-outfit` | Weather-based outfit | fetch + infer |
| `recipe-wizard` | Recipe generation | Fan-out |
| `story-collab` | Collaborative stories | Agent |
| `meme-generator` | Meme captions | Parallel |
| `travel-planner` | Travel itinerary | Agent |
| `movie-night` | Movie recommendations | Conditional |
| `trivia-quiz` | Quiz generation | Linear |
| `fortune-teller` | Daily fortune | Creative |

---

## Package Format

### Directory Structure

Each package follows a minimal structure:

```
packages/@scope/category/package-name/
+-- index.json              # Version metadata (auto-generated)
+-- package.yaml            # Package definition
+-- package-name.md         # Main content (skill/prompt/etc)
+-- workflow.nika.yaml      # (for workflow packages)
```

### package.yaml

```yaml
name: "@nika/generate-page"
version: "1.0.0"
type: workflow
description: Generate a landing page from entity context

files:
  main: generate-page.nika.yaml
  readme: README.md

metadata:
  author: SuperNovae Studio
  license: MIT
  keywords: [nika, workflow, page, generation]

dependencies:
  - "@novanet/core-schema@^0.14.0"
```

### Skill Format (.md)

```markdown
---
name: brainstorming
description: Socratic ideation through collaborative questioning
---

# Brainstorming Skill

## Overview

[Skill content with instructions for Claude/Cursor...]

## Usage

[How to use this skill...]

## Examples

[Example interactions...]
```

### Workflow Format (.nika.yaml)

```yaml
# workflow.nika.yaml
workflow: generate-page
version: "1.0.0"
description: Generate a landing page from entity context

steps:
  - id: load_context
    invoke: novanet_generate
    params:
      entity: "{{input.entity}}"
      locale: "{{input.locale}}"
    use.ctx: entity_context

  - id: generate_content
    infer: |
      Generate a landing page based on this context:
      {{$entity_context}}
    context: $entity_context
    use.out: page_content

  - id: format_output
    exec: "echo '{{$page_content}}' > output.html"
```

---

## Publishing Packages

### Automated Publishing

1. **Fork** this repository
2. **Create** package directory under `packages/@scope/category/`
3. **Add** required files (package.yaml, content files)
4. **Submit** PR — CI auto-generates index.json
5. **Merge** — Package available immediately

### Manual Publishing (with CLI)

```bash
# Authenticate
spn auth login

# Package your content
cd my-package/
spn pack

# Publish to registry
spn publish

# Or publish a specific version
spn publish --version 1.0.0
```

### Version Constraints

We use semver with these constraint patterns:

| Pattern | Meaning |
|---------|---------|
| `1.0.0` | Exact version |
| `^1.0.0` | Compatible (>=1.0.0 <2.0.0) |
| `~1.0.0` | Approximate (>=1.0.0 <1.1.0) |
| `>=1.0.0` | Greater or equal |
| `*` | Any version |

---

## CLI Reference

### Package Commands

| Command | Description |
|---------|-------------|
| `spn add <pkg>` | Add package to manifest and install |
| `spn remove <pkg>` | Remove package |
| `spn install` | Install all from manifest |
| `spn install --frozen` | Install exact versions from lockfile |
| `spn update [pkg]` | Update packages |
| `spn outdated` | List outdated packages |
| `spn search <query>` | Search registry |
| `spn info <pkg>` | Show package details |
| `spn list` | List installed packages |

### Publishing Commands

| Command | Description |
|---------|-------------|
| `spn pack` | Create package tarball |
| `spn publish` | Publish to registry |
| `spn version <bump>` | Bump version (major/minor/patch) |
| `spn yank <pkg@version>` | Yank a version |

### Authentication

| Command | Description |
|---------|-------------|
| `spn auth login` | Authenticate with registry |
| `spn auth logout` | Remove credentials |
| `spn auth status` | Show auth status |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Contribution Guide

1. **Fork** this repository
2. **Create** a feature branch: `git checkout -b feat/my-package`
3. **Add** your package under `packages/@scope/`
4. **Test** locally: `spn add file:./packages/@scope/my-package`
5. **Submit** a PR with description

### Package Guidelines

- **Skills**: Markdown with YAML frontmatter, actionable instructions
- **Workflows**: Valid `.nika.yaml` with DAG definition
- **Schemas**: NovaNet node/arc class definitions
- **Prompts**: Template strings with `{{variable}}` placeholders

### Quality Checklist

- [ ] Package has `package.yaml` with all required fields
- [ ] Main content file exists and is valid
- [ ] Description is clear and accurate
- [ ] Keywords help discoverability
- [ ] License is specified (default: MIT)

---

## Related Projects

| Project | Description |
|---------|-------------|
| [spn (supernovae-cli)](https://github.com/supernovae-st/supernovae-cli) | CLI for package management |
| [Nika](https://github.com/supernovae-st/nika) | Semantic YAML workflow engine |
| [NovaNet](https://github.com/supernovae-st/novanet) | Knowledge graph for localization |
| [supernovae-index](https://github.com/supernovae-st/supernovae-index) | Sparse package index |
| [homebrew-tap](https://github.com/supernovae-st/homebrew-tap) | Homebrew formulas |

---

## License

MIT (c) [SuperNovae Studio](https://supernovae.studio)

---

**Links:** [Documentation](https://docs.supernovae.studio) | [CLI Guide](https://github.com/supernovae-st/supernovae-cli) | [Discord](https://discord.gg/supernovae)
