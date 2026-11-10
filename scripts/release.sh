#!/usr/bin/env bash

set -euo pipefail

WORLD_JSON=world/archipelago.json
MANIFEST=client/manifest.json
MOD_ID=JLannoo-DesveladoAP

die() { echo "error: $*" >&2; exit 1; }

ask() { 
    read -p "$1 (y/n) " -n 1 -r;
    if ! [[ $REPLY =~ ^[Yy]$ ]]
        then exit 1
    fi
}

bump() {
    local version="${1:-}"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || die "usage: $0 bump <x.y.z[-prerelease]>"
    local tag="v$version"
    # Base version trims -prerelease because archipelago doesn't like that syntax
    local base="${version%%-*}"

    if [[ -n "$(git status --porcelain)" ]]; then 
        ask "working tree has unstaged changes, continue?"
    fi

    git rev-parse -q --verify "refs/tags/$tag" >/dev/null && die "tag $tag already exists"

    # write version
    sed -E -i "s/(\"world_version\"[[:space:]]*:[[:space:]]*\")[^\"]*\"/\1$base\"/" "$WORLD_JSON"
    sed -E -i "s/(\"version_number\"[[:space:]]*:[[:space:]]*\")[^\"]*\"/\1$base\"/" "$MANIFEST"
    # compare version
    [[ "$(jq -r .world_version "$WORLD_JSON")" == "$base" ]] || die "failed to set version in $WORLD_JSON"
    [[ "$(jq -r .version_number "$MANIFEST")" == "$base" ]] || die "failed to set version in $MANIFEST"

    if [[ -n "$(git status --porcelain)" ]]; then
        git add "$WORLD_JSON" "$MANIFEST"
        git commit -m "chore: release $tag"
    else
        echo "version already is $base, tagging current commit"
    fi

    git tag -a "$tag" -m "$tag"
}

publish() {
    local mod_zip="${1:-}"
    [[ -f "$mod_zip" ]] || die "usage: $0 publish <path/to/exported mod zip>"

    if [[ -n "$(git status --porcelain)" ]]; then 
        ask "working tree has unstaged changes, continue?"
    fi

    local tag
    tag="$(git tag --points-at HEAD --list 'v*' | head -n1)"
    [[ -n "$tag" ]] || die "HEAD has no v* tag, run '$0 bump <version>' first"

    local version="${tag#v}"
    local base="${version%%-*}"

    # Check versions match
    local zip_manifest="mods-unpacked/$MOD_ID/manifest.json"
    local zip_version
    zip_version="$(unzip -p "$mod_zip" "$zip_manifest" 2>/dev/null | jq -r .version_number)" \
        || die "$mod_zip has no $zip_manifest"
    [[ "$zip_version" == "$base" ]] || die "mod zip is version $zip_version but $tag expects $base"

    rm -rf dist && mkdir dist
    
    git archive --format=zip --prefix=desvelado/ -o dist/desvelado.apworld "$tag:world"
    cp "$mod_zip" "dist/$MOD_ID.zip"

    local prerelease=()
    [[ "$version" == *-* ]] && prerelease=(--prerelease)

    git push origin HEAD "$tag"
    gh release create "$tag" dist/desvelado.apworld "dist/$MOD_ID.zip" \
        --title "$tag" --generate-notes "${prerelease[@]}"
}

case "${1:-}" in
    bump)    shift; bump "$@" ;;
    publish) shift; publish "$@" ;;
    *) echo "it's 'bump' or 'publish', dumbass"
esac
