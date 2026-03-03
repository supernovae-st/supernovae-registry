#!/usr/bin/env bash
#
# Verify all tarball checksums match index entries
#
# Usage: ./scripts/verify-checksums.sh

set -euo pipefail

REGISTRY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REGISTRY_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
VERIFIED=0

echo "🔍 Verifying checksums..."
echo ""

# Find all index files
while IFS= read -r index_file; do
    # Parse each line (NDJSON)
    while IFS= read -r line; do
        [ -z "$line" ] && continue

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
            skills) PREFIX="s" ;;
            prompts) PREFIX="p" ;;
            jobs) PREFIX="j" ;;
            community) PREFIX="c" ;;
            *) PREFIX="${SCOPE:0:1}" ;;
        esac

        TARBALL="releases/@$PREFIX/$PATH_PART/$VERSION.tar.gz"

        if [ ! -f "$TARBALL" ]; then
            echo -e "${RED}❌ Missing tarball:${NC} $TARBALL"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        # Compute actual checksum
        if command -v sha256sum &> /dev/null; then
            ACTUAL_CKSUM=$(sha256sum "$TARBALL" | awk '{print $1}')
        elif command -v shasum &> /dev/null; then
            ACTUAL_CKSUM=$(shasum -a 256 "$TARBALL" | awk '{print $1}')
        else
            echo -e "${RED}❌ No SHA256 tool found${NC}"
            exit 1
        fi

        if [ "$EXPECTED_CKSUM" != "$ACTUAL_CKSUM" ]; then
            echo -e "${RED}❌ Checksum mismatch:${NC} $NAME@$VERSION"
            echo "   Expected: $EXPECTED_CKSUM"
            echo "   Actual:   $ACTUAL_CKSUM"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}✅${NC} $NAME@$VERSION"
            VERIFIED=$((VERIFIED + 1))
        fi
    done < "$index_file"
done < <(find index -type f 2>/dev/null || true)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Verified: $VERIFIED"
echo "  Errors:   $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Verification failed with $ERRORS errors${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All checksums verified!${NC}"
