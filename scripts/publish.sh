#!/usr/bin/env bash
#
# Publish a package to the SuperNovae Registry
#
# Usage: ./scripts/publish.sh <package-dir>
#
# Example: ./scripts/publish.sh ~/.spn/packages/workflows/test-integration/1.0.0

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
error() {
    echo -e "${RED}❌ Error:${NC} $*" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅${NC} $*"
}

info() {
    echo -e "${BLUE}ℹ️${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $*"
}

# Check arguments
if [ $# -ne 1 ]; then
    error "Usage: $0 <package-dir>"
fi

PACKAGE_DIR="$1"

# Validate package directory
if [ ! -d "$PACKAGE_DIR" ]; then
    error "Package directory not found: $PACKAGE_DIR"
fi

if [ ! -f "$PACKAGE_DIR/manifest.yaml" ]; then
    error "manifest.yaml not found in $PACKAGE_DIR"
fi

# Get registry root (parent of scripts/)
REGISTRY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REGISTRY_ROOT"

info "Publishing package from: $PACKAGE_DIR"
info "Registry root: $REGISTRY_ROOT"

# Parse manifest using yq (or fallback to grep/sed)
if command -v yq &> /dev/null; then
    PACKAGE_NAME=$(yq eval '.name' "$PACKAGE_DIR/manifest.yaml")
    PACKAGE_VERSION=$(yq eval '.version' "$PACKAGE_DIR/manifest.yaml")
    PACKAGE_TYPE=$(yq eval '.type' "$PACKAGE_DIR/manifest.yaml")
else
    # Fallback to grep/sed/awk
    PACKAGE_NAME=$(grep '^name:' "$PACKAGE_DIR/manifest.yaml" | awk '{print $2}' | tr -d '"')
    PACKAGE_VERSION=$(grep '^version:' "$PACKAGE_DIR/manifest.yaml" | awk '{print $2}' | tr -d '"')
    PACKAGE_TYPE=$(grep '^type:' "$PACKAGE_DIR/manifest.yaml" | awk '{print $2}' | tr -d '"')
fi

# Validate extracted values
if [ -z "$PACKAGE_NAME" ]; then
    error "Could not extract package name from manifest.yaml"
fi

if [ -z "$PACKAGE_VERSION" ]; then
    error "Could not extract package version from manifest.yaml"
fi

if [ -z "$PACKAGE_TYPE" ]; then
    error "Could not extract package type from manifest.yaml"
fi

info "Package: $PACKAGE_NAME"
info "Version: $PACKAGE_VERSION"
info "Type: $PACKAGE_TYPE"

# Validate package name format (@scope/path)
if [[ ! "$PACKAGE_NAME" =~ ^@[a-z]+/ ]]; then
    error "Invalid package name format: $PACKAGE_NAME (must start with @scope/)"
fi

# Extract scope and path
SCOPE=$(echo "$PACKAGE_NAME" | sed 's/@\([^/]*\)\/.*/\1/')
PATH_PART=$(echo "$PACKAGE_NAME" | sed 's/@[^/]*\/\(.*\)/\1/')

# Map scope to prefix (w=workflows, n=nika, c=community)
case "$SCOPE" in
    workflows)
        PREFIX="w"
        ;;
    nika)
        PREFIX="n"
        ;;
    community)
        PREFIX="c"
        ;;
    agents)
        PREFIX="a"
        ;;
    skills)
        PREFIX="s"
        ;;
    prompts)
        PREFIX="p"
        ;;
    jobs)
        PREFIX="j"
        ;;
    *)
        PREFIX="${SCOPE:0:1}"
        ;;
esac

info "Scope: $SCOPE (prefix: $PREFIX)"
info "Path: $PATH_PART"

# Create tarball
RELEASE_DIR="releases/@$PREFIX/$PATH_PART"
mkdir -p "$RELEASE_DIR"

TARBALL_NAME="$PACKAGE_VERSION.tar.gz"
TARBALL_PATH="$RELEASE_DIR/$TARBALL_NAME"

info "Creating tarball: $TARBALL_PATH"

# Create tarball from package directory
tar czf "$TARBALL_PATH" -C "$PACKAGE_DIR" .

success "Tarball created"

# Compute SHA256 checksum
if command -v sha256sum &> /dev/null; then
    CHECKSUM=$(sha256sum "$TARBALL_PATH" | awk '{print $1}')
elif command -v shasum &> /dev/null; then
    CHECKSUM=$(shasum -a 256 "$TARBALL_PATH" | awk '{print $1}')
else
    error "No SHA256 tool found (sha256sum or shasum required)"
fi

info "Checksum: sha256:$CHECKSUM"

# Create index entry (NDJSON format)
INDEX_FILE="index/@$PREFIX/$PATH_PART"
mkdir -p "$(dirname "$INDEX_FILE")"

# Generate NDJSON entry
INDEX_ENTRY=$(cat <<EOF
{"name":"$PACKAGE_NAME","vers":"$PACKAGE_VERSION","deps":[],"cksum":"sha256:$CHECKSUM","features":{},"yanked":false}
EOF
)

# Append to index file
echo "$INDEX_ENTRY" >> "$INDEX_FILE"

success "Index entry added to: $INDEX_FILE"

# Show summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}📦 Package Published${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Name:     $PACKAGE_NAME"
echo "  Version:  $PACKAGE_VERSION"
echo "  Type:     $PACKAGE_TYPE"
echo ""
echo "  Tarball:  $TARBALL_PATH"
echo "  Index:    $INDEX_FILE"
echo "  Checksum: sha256:$CHECKSUM"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Next steps
echo "Next steps:"
echo "  1. Review changes: git status"
echo "  2. Commit and push:"
echo "     git add releases/ index/"
echo "     git commit -m \"📦 publish: $PACKAGE_NAME@$PACKAGE_VERSION\""
echo "     git push origin main"
echo ""
echo "  3. Test installation:"
echo "     spn add $PACKAGE_NAME"
echo ""

info "Done!"
