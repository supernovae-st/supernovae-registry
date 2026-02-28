# @nika/seo-audit

SEO audit workflow with NovaNet entity context enrichment.

## Features

- Fetches and analyzes any web page for SEO best practices
- Optionally enriches analysis with NovaNet entity context
- Generates both structured JSON and markdown reports
- Locale-aware recommendations

## Installation

```bash
spn add @nika/seo-audit
```

## Usage

```bash
# Basic usage
nika run @nika/seo-audit --url "https://example.com" --locale "en-US"

# With NovaNet entity context
nika run @nika/seo-audit \
  --url "https://qrcode-ai.com" \
  --locale "fr-FR" \
  --entity "qr-code"
```

## Inputs

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `url` | string | yes | - | URL of the page to audit |
| `locale` | string | yes | `en-US` | Target locale (BCP-47) |
| `entity` | string | no | - | NovaNet entity key for context |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `report` | object | Structured JSON report with scores |
| `markdown` | string | Human-readable markdown summary |

## Report Structure

```json
{
  "url": "https://example.com",
  "locale": "en-US",
  "overall_score": 75,
  "categories": [
    {
      "name": "Title Tag",
      "score": 8,
      "findings": ["Title present", "Good length"],
      "recommendations": ["Add primary keyword"]
    }
  ],
  "priority_actions": ["Add meta description", "Fix H1 hierarchy"],
  "timestamp": "2026-02-28T10:00:00Z"
}
```

## Requirements

- Nika v0.9.0+
- NovaNet MCP Server (optional, for entity context)

## License

MIT
