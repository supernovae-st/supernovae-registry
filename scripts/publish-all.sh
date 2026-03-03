#!/usr/bin/env bash
#
# Publish all packages in the registry
#
# Usage: ./scripts/publish-all.sh

set -euo pipefail

REGISTRY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REGISTRY_ROOT"

echo "🚀 Publishing all packages..."
echo ""

TOTAL=0
SUCCESS=0
FAILED=0

# Find all package directories (those containing package.yaml or manifest.yaml)
while IFS= read -r manifest; do
    PKG_DIR=$(dirname "$manifest")
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 [$TOTAL] Publishing: $PKG_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if ./scripts/publish.sh "$PKG_DIR"; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
        echo "⚠️ Failed: $PKG_DIR"
    fi
done < <(find packages -type f \( -name "package.yaml" -o -name "manifest.yaml" \))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Bulk Publish Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Total:   $TOTAL"
echo "  Success: $SUCCESS"
echo "  Failed:  $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "⚠️ Some packages failed to publish"
else
    echo "✅ All packages published successfully!"
fi

echo ""
echo "Next steps:"
echo "  1. Review changes: git status"
echo "  2. Commit and push:"
echo "     git add releases/ index/"
echo "     git commit -m '📦 publish: bulk publish all $SUCCESS packages'"
echo "     git push origin main"
echo ""
