# SuperNovae Registry Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make `spn add @workflows/fun/movie-night` work by generating all tarballs and setting up CI/CD.

**Architecture:** Git-native sparse index (Cargo-style) with NDJSON metadata, SHA256 checksums, and GitHub Actions for automated publishing.

**Tech Stack:** Bash scripts, GitHub Actions, NDJSON, tar/gzip, SHA256

---

## Current State Analysis

| Asset | Count | Status |
|-------|-------|--------|
| Packages in `packages/` | 18 | ✅ YAML files exist |
| Index entries | 21 | ⚠️ Partial (some orphan) |
| Tarballs in `releases/` | 3 | ❌ Missing 15 packages |
| config.json | 1 | ❌ Wrong download URL |

**Critical Issue:** `config.json` points to `supernovae-powers` instead of `supernovae-registry`:
```json
{
  "dl": "https://github.com/supernovae-st/supernovae-powers/releases/download/{name}/{version}.tar.gz"
}
```

---

## Option A: Generate All Tarballs (Manual Bootstrap)

### Task 1: Fix config.json

**Files:**
- Modify: `config.json`

**Step 1: Update download URL**

```json
{
  "dl": "https://raw.githubusercontent.com/supernovae-st/supernovae-registry/main/releases/{name}/{version}.tar.gz",
  "api": "https://api.supernovae.sh",
  "registry": "https://github.com/supernovae-st/supernovae-registry",
  "version": 1
}
```

**Step 2: Verify change**

Run: `cat config.json`
Expected: Download URL points to `supernovae-registry/main/releases`

**Step 3: Commit**

```bash
git add config.json
git commit -m "fix(config): correct download URL to supernovae-registry"
```

---

### Task 2: Fix publish.sh to support package.yaml

**Files:**
- Modify: `scripts/publish.sh`

**Step 1: Update manifest detection**

Change line that checks for `manifest.yaml` to also support `package.yaml`:

```bash
# Check for package metadata file (manifest.yaml or package.yaml)
if [ -f "$PACKAGE_DIR/manifest.yaml" ]; then
    MANIFEST_FILE="$PACKAGE_DIR/manifest.yaml"
elif [ -f "$PACKAGE_DIR/package.yaml" ]; then
    MANIFEST_FILE="$PACKAGE_DIR/package.yaml"
else
    error "No manifest.yaml or package.yaml found in $PACKAGE_DIR"
fi
```

**Step 2: Update all references from hardcoded manifest.yaml to $MANIFEST_FILE**

**Step 3: Test with one package**

Run: `./scripts/publish.sh packages/@workflows/fun/movie-night`
Expected: Tarball created in `releases/@w/fun/movie-night/`

**Step 4: Commit**

```bash
git add scripts/publish.sh
git commit -m "fix(publish): support both manifest.yaml and package.yaml"
```

---

### Task 3: Create bulk publish script

**Files:**
- Create: `scripts/publish-all.sh`

**Step 1: Write the bulk publish script**

```bash
#!/usr/bin/env bash
#
# Publish all packages in the registry
#
# Usage: ./scripts/publish-all.sh

set -euo pipefail

REGISTRY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REGISTRY_ROOT"

echo "🚀 Publishing all packages..."

# Find all package directories (those containing package.yaml or manifest.yaml)
find packages -type f \( -name "package.yaml" -o -name "manifest.yaml" \) | while read -r manifest; do
    PKG_DIR=$(dirname "$manifest")
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Publishing: $PKG_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ./scripts/publish.sh "$PKG_DIR" || echo "⚠️ Failed: $PKG_DIR"
done

echo ""
echo "✅ Bulk publish complete!"
echo ""
echo "Run: git status"
echo "Then: git add releases/ index/ && git commit -m '📦 publish: all packages'"
```

**Step 2: Make executable**

Run: `chmod +x scripts/publish-all.sh`

**Step 3: Commit**

```bash
git add scripts/publish-all.sh
git commit -m "feat(scripts): add bulk publish-all.sh"
```

---

### Task 4: Execute bulk publish

**Step 1: Run publish-all**

Run: `./scripts/publish-all.sh`
Expected: 18 packages processed, tarballs created in releases/

**Step 2: Verify tarball count**

Run: `find releases -name "*.tar.gz" | wc -l`
Expected: 18+ (at least one per package)

**Step 3: Verify index entries**

Run: `find index -type f | wc -l`
Expected: 18+ index files

**Step 4: Commit all generated files**

```bash
git add releases/ index/
git commit -m "📦 publish: bulk publish all 18 packages

- Generated tarballs for all packages
- Updated index entries with checksums
- Ready for spn add commands"
```

---

### Task 5: Test spn add locally

**Step 1: Push to GitHub**

Run: `git push origin main`

**Step 2: Test installation**

Run: `spn add @workflows/fun/movie-night`
Expected: Package downloads and extracts to ~/.spn/packages/

**Step 3: Verify installed package**

Run: `ls ~/.spn/packages/@workflows/fun/movie-night/`
Expected: Package files present

---

## Option B: Setup GitHub Actions CI/CD

### Task 6: Create publish workflow

**Files:**
- Create: `.github/workflows/publish.yml`

**Step 1: Write the workflow**

```yaml
name: Publish Package

on:
  push:
    paths:
      - 'packages/**'
    branches:
      - main

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - name: Find changed packages
        id: changes
        run: |
          # Get changed package directories
          CHANGED=$(git diff --name-only HEAD~1 HEAD -- packages/ | \
            xargs -I {} dirname {} | \
            sort -u | \
            grep -E 'packages/@[a-z]+/' || true)

          if [ -z "$CHANGED" ]; then
            echo "No package changes detected"
            echo "packages=" >> $GITHUB_OUTPUT
          else
            echo "Changed packages:"
            echo "$CHANGED"
            echo "packages<<EOF" >> $GITHUB_OUTPUT
            echo "$CHANGED" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          fi

      - name: Publish changed packages
        if: steps.changes.outputs.packages != ''
        run: |
          echo "${{ steps.changes.outputs.packages }}" | while read -r pkg_dir; do
            if [ -n "$pkg_dir" ] && [ -d "$pkg_dir" ]; then
              echo "Publishing: $pkg_dir"
              ./scripts/publish.sh "$pkg_dir"
            fi
          done

      - name: Commit and push
        if: steps.changes.outputs.packages != ''
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          git add releases/ index/

          if git diff --staged --quiet; then
            echo "No changes to commit"
          else
            git commit -m "📦 ci: auto-publish updated packages"
            git push
          fi
```

**Step 2: Commit**

```bash
git add .github/workflows/publish.yml
git commit -m "ci(publish): add auto-publish workflow on package changes"
```

---

### Task 7: Create validation workflow

**Files:**
- Create: `.github/workflows/validate.yml`

**Step 1: Write the validation workflow**

```yaml
name: Validate Packages

on:
  pull_request:
    paths:
      - 'packages/**'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install yq
        run: |
          sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
          sudo chmod +x /usr/local/bin/yq

      - name: Validate package.yaml files
        run: |
          ERRORS=0

          find packages -name "package.yaml" -o -name "manifest.yaml" | while read -r manifest; do
            echo "Validating: $manifest"

            # Check required fields
            NAME=$(yq eval '.name' "$manifest")
            VERSION=$(yq eval '.version' "$manifest")
            TYPE=$(yq eval '.type' "$manifest")

            if [ "$NAME" = "null" ] || [ -z "$NAME" ]; then
              echo "❌ Missing 'name' in $manifest"
              ERRORS=$((ERRORS + 1))
            fi

            if [ "$VERSION" = "null" ] || [ -z "$VERSION" ]; then
              echo "❌ Missing 'version' in $manifest"
              ERRORS=$((ERRORS + 1))
            fi

            if [ "$TYPE" = "null" ] || [ -z "$TYPE" ]; then
              echo "❌ Missing 'type' in $manifest"
              ERRORS=$((ERRORS + 1))
            fi

            # Validate name format
            if [[ ! "$NAME" =~ ^@[a-z]+/ ]]; then
              echo "❌ Invalid name format: $NAME (must start with @scope/)"
              ERRORS=$((ERRORS + 1))
            fi

            # Validate version format (semver)
            if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
              echo "❌ Invalid version format: $VERSION (must be semver)"
              ERRORS=$((ERRORS + 1))
            fi
          done

          if [ $ERRORS -gt 0 ]; then
            echo ""
            echo "❌ Validation failed with $ERRORS errors"
            exit 1
          fi

          echo "✅ All packages valid"

      - name: Check for duplicate versions
        run: |
          find packages -name "package.yaml" -o -name "manifest.yaml" | while read -r manifest; do
            NAME=$(yq eval '.name' "$manifest")
            VERSION=$(yq eval '.version' "$manifest")

            # Check if version already exists in index
            # Map scope to prefix
            SCOPE=$(echo "$NAME" | sed 's/@\([^/]*\)\/.*/\1/')
            PATH_PART=$(echo "$NAME" | sed 's/@[^/]*\/\(.*\)/\1/')

            case "$SCOPE" in
              workflows) PREFIX="w" ;;
              nika) PREFIX="n" ;;
              agents) PREFIX="a" ;;
              *) PREFIX="${SCOPE:0:1}" ;;
            esac

            INDEX_FILE="index/@$PREFIX/$PATH_PART"

            if [ -f "$INDEX_FILE" ]; then
              if grep -q "\"vers\":\"$VERSION\"" "$INDEX_FILE"; then
                echo "⚠️ Warning: Version $VERSION already published for $NAME"
              fi
            fi
          done
```

**Step 2: Commit**

```bash
git add .github/workflows/validate.yml
git commit -m "ci(validate): add PR validation workflow"
```

---

### Task 8: Create checksum verification

**Files:**
- Create: `scripts/verify-checksums.sh`

**Step 1: Write verification script**

```bash
#!/usr/bin/env bash
#
# Verify all tarball checksums match index entries
#
# Usage: ./scripts/verify-checksums.sh

set -euo pipefail

REGISTRY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REGISTRY_ROOT"

ERRORS=0

echo "🔍 Verifying checksums..."

find index -type f | while read -r index_file; do
    # Parse each line (NDJSON)
    while IFS= read -r line; do
        NAME=$(echo "$line" | jq -r '.name')
        VERSION=$(echo "$line" | jq -r '.vers')
        EXPECTED_CKSUM=$(echo "$line" | jq -r '.cksum' | sed 's/sha256://')

        # Find tarball
        SCOPE=$(echo "$NAME" | sed 's/@\([^/]*\)\/.*/\1/')
        PATH_PART=$(echo "$NAME" | sed 's/@[^/]*\/\(.*\)/\1/')

        case "$SCOPE" in
            workflows) PREFIX="w" ;;
            nika) PREFIX="n" ;;
            agents) PREFIX="a" ;;
            *) PREFIX="${SCOPE:0:1}" ;;
        esac

        TARBALL="releases/@$PREFIX/$PATH_PART/$VERSION.tar.gz"

        if [ ! -f "$TARBALL" ]; then
            echo "❌ Missing tarball: $TARBALL"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        # Compute actual checksum
        if command -v sha256sum &> /dev/null; then
            ACTUAL_CKSUM=$(sha256sum "$TARBALL" | awk '{print $1}')
        else
            ACTUAL_CKSUM=$(shasum -a 256 "$TARBALL" | awk '{print $1}')
        fi

        if [ "$EXPECTED_CKSUM" != "$ACTUAL_CKSUM" ]; then
            echo "❌ Checksum mismatch: $NAME@$VERSION"
            echo "   Expected: $EXPECTED_CKSUM"
            echo "   Actual:   $ACTUAL_CKSUM"
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ $NAME@$VERSION"
        fi
    done < "$index_file"
done

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "❌ Verification failed with $ERRORS errors"
    exit 1
fi

echo ""
echo "✅ All checksums verified!"
```

**Step 2: Make executable and commit**

```bash
chmod +x scripts/verify-checksums.sh
git add scripts/verify-checksums.sh
git commit -m "feat(scripts): add checksum verification"
```

---

### Task 9: Push all changes and test

**Step 1: Push all commits**

Run: `git push origin main`

**Step 2: Verify GitHub Actions**

Check: https://github.com/supernovae-st/supernovae-registry/actions
Expected: Workflows visible, no errors

**Step 3: Test end-to-end**

```bash
# Clear local cache
rm -rf ~/.spn/packages/@workflows

# Test installation
spn add @workflows/fun/movie-night

# Verify
ls ~/.spn/packages/@workflows/fun/movie-night/
nika check ~/.spn/packages/@workflows/fun/movie-night/*.nika.yaml
```

---

## Summary

| Task | Description | Time |
|------|-------------|------|
| 1 | Fix config.json download URL | 2 min |
| 2 | Fix publish.sh for package.yaml | 10 min |
| 3 | Create publish-all.sh | 5 min |
| 4 | Execute bulk publish | 5 min |
| 5 | Test spn add | 5 min |
| 6 | Create publish workflow | 15 min |
| 7 | Create validation workflow | 15 min |
| 8 | Create verify-checksums.sh | 10 min |
| 9 | Push and test | 5 min |
| **Total** | | **~72 min** |

## Best Practices Applied (from Research)

1. **Sparse Index Format** (Cargo-style): NDJSON with one JSON line per version
2. **SHA256 Checksums**: Verify integrity before extraction
3. **Scope-to-Prefix Mapping**: `@workflows/` → `@w/`, `@agents/` → `@a/`
4. **Git-Native Hosting**: Use raw.githubusercontent.com for downloads
5. **CI/CD Automation**: Auto-publish on push, validate on PR
6. **Idempotent Publishing**: Check for existing versions before publish
