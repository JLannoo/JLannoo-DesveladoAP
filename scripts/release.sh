#!/usr/bin/env bash
# Usage: scripts/release.sh <version>   e.g. scripts/release.sh 0.1.0
# Sets the version in the world and the client, commits, and tags v<version>.
# Pushing is left to you: git push --follow-tags
set -euo pipefail

VERSION="${1:-}"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]]; then
    echo "usage: $0 <x.y.z[-prerelease]>" >&2
    exit 1
fi
TAG="v$VERSION"

cd "$(git rev-parse --show-toplevel)"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: working tree is not clean, commit or stash first" >&2
    exit 1
fi
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    echo "error: tag $TAG already exists" >&2
    exit 1
fi

WORLD_JSON=world/archipelago.json
MANIFEST=client/manifest.json

# sed instead of a JSON rewrite, to keep the files' formatting intact
sed -E -i "s/(\"world_version\"[[:space:]]*:[[:space:]]*\")[^\"]*\"/\1$VERSION\"/" "$WORLD_JSON"
sed -E -i "s/(\"version_number\"[[:space:]]*:[[:space:]]*\")[^\"]*\"/\1$VERSION\"/" "$MANIFEST"

for f in "$WORLD_JSON" "$MANIFEST"; do
    grep -q "\"$VERSION\"" "$f" || { echo "error: failed to set version in $f" >&2; exit 1; }
done

if [[ -n "$(git status --porcelain)" ]]; then
    git add "$WORLD_JSON" "$MANIFEST"
    git commit -m "chore: release $TAG"
else
    echo "version already $VERSION, tagging current commit"
fi

git tag -a "$TAG" -m "$TAG"
echo "tagged $TAG — push with: git push --follow-tags"
