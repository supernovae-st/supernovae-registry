# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-03-05

╔═══════════════════════════════════════════════════════════════════════════════╗
║  📦 SUPERNOVAE REGISTRY v2.0.0 — PUBLIC PACKAGE REGISTRY                      ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  📦 46 Packages  │  🔓 MIT License  │  🎯 6 Types  │  🦋 Nika + NovaNet       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

### ✨ Highlights

| Feature | Status | Impact |
|---------|--------|--------|
| **📦 46 Packages** | ✅ Ready | Workflows, schemas, skills, prompts, jobs, agents |
| **🔓 MIT License** | ✅ Open | Free for everyone |
| **📋 Sparse Index** | ✅ Fast | Cargo-inspired efficient resolution |
| **🦋 Nika Integration** | ✅ Complete | YAML workflow engine compatibility |

### 🏗️ Registry Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  PUBLIC REGISTRY v2 — SPARSE INDEX PATTERN                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  Package Types (6)                                                              │
│  ├── @workflows/     → Nika YAML DAG workflows (.nika.yaml)                    │
│  ├── @schemas/       → NovaNet node/arc classes                                │
│  ├── @skills/        → Skill definitions for Claude/Cursor                     │
│  ├── @prompts/       → Prompt templates                                        │
│  ├── @jobs/          → Scheduled/triggered jobs                                │
│  └── @agents/        → Agent configurations                                    │
│                                                                                 │
│  Alternate Scopes (aliases)                                                     │
│  ├── @nika/          → alias for @workflows/                                   │
│  ├── @novanet/       → alias for @schemas/                                     │
│  └── @shared/        → alias for @skills/ (cross-project)                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Added

- **📦 46 packages**: Complete package ecosystem for AI workflows
  - `@workflows/` — 31 ready-to-use workflow templates
  - `@schemas/` — 2 NovaNet graph schemas
  - `@skills/` — 10 cross-project development skills
  - `@prompts/` — 2 prompt templates
  - `@jobs/` — 1 scheduled job

- **📋 Sparse index**: Cargo-inspired package resolution
  - `index.json` per package with version metadata
  - SHA256 checksum verification
  - Semver constraint support (^, ~, >=, *)

- **🦋 Nika packages** (`@nika/`):
  - `nika-run` — Run workflows with validation
  - `nika-debug` — Debug with traces and logging
  - `nika-spec` — Workflow specification reference
  - `nika-yaml` — YAML authoring guide
  - `nika-binding` — Data binding syntax
  - `nika-arch` — Architecture diagrams
  - `nika-diagnose` — Troubleshooting checklist
  - `workflow-validate` — Schema validation

- **🧠 NovaNet packages** (`@novanet/`):
  - `schema-validate` — Schema validation patterns
  - `novanet-yaml` — YAML schema authoring

- **🔧 Shared skills** (`@shared/`):
  - `brainstorming` — Socratic ideation
  - `test-driven-development` — TDD methodology
  - `systematic-debugging` — 4-phase debugging
  - `code-review` — Automated code review
  - `codebase-audit` — Dead code detection
  - `security-audit` — Vulnerability scanning
  - `token-audit` — API token management
  - `workspace-nav` — Project navigation
  - `release` — Release automation
  - `adr` — Architecture Decision Records

- **📋 Workflow templates** (`@workflows/`):
  - Dev Productivity: 8 workflows (PR description, changelog, README, code review...)
  - Content Creation: 6 workflows (blog, social media, landing page...)
  - Research & Analysis: 5 workflows (web research, competitor analysis...)
  - Data Processing: 4 workflows (JSON transformer, CSV analyzer...)
  - Fun & Entertainment: 8 workflows (weather outfit, recipe wizard...)

- **🔐 GitHub Actions CI**: Auto-validation and auto-publish on PR merge

### 🦋 🐔 🐤 Mascots

```
╭─────────────────────────────────────────────────────────────────────────────────╮
│  MASCOT HIERARCHY                                                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│                              NIKA (Papillon)                                    │
│                                   Runtime                                       │
│                        Orchestrates the 5 semantic verbs                        │
│                                      │                                          │
│          ┌───────────┬───────────┬───┴───┬───────────┬───────────┐              │
│          ▼           ▼           ▼       ▼           ▼                          │
│       infer:      exec:       fetch:  invoke:    agent:                         │
│        LLM        Shell        HTTP     MCP    (Space Chicken)                  │
│                                                    │                            │
│                                              spawn_agent                        │
│                                                    │                            │
│                                         ┌─────────┴─────────┐                   │
│                                         ▼         ▼         ▼                   │
│                                      (Subagents - Poussins)                     │
│                                                                                 │
│  Important: Nika is NOT an agent. Nika is the runtime that orchestrates agents │
│                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────╯
```

### 📊 Statistics

```
╭─────────────────────────────────────────────────────────────────────────────────╮
│  📊 v2.0.0 METRICS                                                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  📦 Packages:     46 total                                                     │
│  📋 Workflows:    31 (@workflows/)                                             │
│  🧠 Schemas:      2 (@schemas/)                                                │
│  🔧 Skills:       10 (@skills/)                                                │
│  📝 Prompts:      2 (@prompts/)                                                │
│  ⏰ Jobs:         1 (@jobs/)                                                   │
│  🔓 License:      MIT                                                          │
│                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────╯
```

---

## [1.0.0] - 2026-02-28

### Added

- **Initial registry setup**: Basic structure with 17 workflows
- **Package index**: Root `index.json` for package discovery
- **README documentation**: Comprehensive v1 documentation

---

[Unreleased]: https://github.com/supernovae-studio/supernovae-registry/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/supernovae-studio/supernovae-registry/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/supernovae-studio/supernovae-registry/releases/tag/v1.0.0
