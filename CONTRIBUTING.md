# Contributing to SuperNovae Registry

Thank you for your interest in contributing! This document provides guidelines for contributing packages to the registry.

---

## Package Types

| Type | Extension | Description |
|------|-----------|-------------|
| **Skill** | `.md` | Instructions for Claude Code/Cursor |
| **Workflow** | `.nika.yaml` | Nika DAG workflow definition |
| **Agent** | `.yaml` | Agent configuration with tools |

---

## Adding a New Package

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/supernovae-registry.git
cd supernovae-registry
```

### 2. Create Package Directory

```bash
# Choose the appropriate scope
mkdir -p packages/@workflows/category/your-package
# or
mkdir -p packages/@shared/your-package
```

### 3. Add Your Content

For workflows (`.nika.yaml`):

```yaml
# your-package.nika.yaml
schema: "nika/workflow@0.5"
workflow: your-package
description: "What this workflow does"
provider: claude

tasks:
  - id: step1
    infer: "Your prompt here"
    # ... more tasks
```

For skills (`.md`):

```markdown
---
name: your-skill
description: Brief description
---

# Your Skill Name

Instructions for Claude/Cursor...
```

### 4. Package.yaml (Auto-Generated)

Don't create this manually — it's generated on publish. But for reference:

```yaml
name: "@scope/your-package"
version: 1.0.0
type: workflow  # or skill, agent
description: "Brief description"

files:
  main: your-package.nika.yaml

metadata:
  author: Your Name
  license: MIT
  keywords: [relevant, keywords]
```

### 5. Submit PR

```bash
git checkout -b add-your-package
git add .
git commit -m "feat(@scope): add your-package"
git push origin add-your-package
```

---

## Guidelines

### Naming

- Use `kebab-case` for package names
- Be descriptive: `pr-description` not `pr`
- Prefix with action: `generate-`, `audit-`, `sync-`

### Quality

- Test your workflow locally with `nika check`
- Include usage examples in comments
- Document required environment variables
- Keep workflows focused (single purpose)

### Patterns

Use established Nika patterns:

| Pattern | Use Case |
|---------|----------|
| Linear DAG | Sequential steps |
| Fan-out | Parallel processing |
| Agent loop | Multi-turn reasoning |
| MCP invoke | External tool calls |

---

## Code of Conduct

- Be respectful and inclusive
- Help newcomers
- Provide constructive feedback
- No spam or self-promotion

---

## Questions?

Open an issue or reach out at [hello@supernovae.sh](mailto:hello@supernovae.sh)
