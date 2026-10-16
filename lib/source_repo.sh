#!/usr/bin/env bash

source_repo() {
    local name="$1" override="$2" target
    if [[ -n "$override" ]]; then
        [[ -d "$override" ]] || fail "Source override does not exist: $override"
        # Explicit local sources are used as-is, never pulled or reset.
        (cd "$override" && pwd)
        return
    fi
    target="$ASSET_SOURCE_CACHE/$name"
    mkdir -p "$ASSET_SOURCE_CACHE"
    if [[ -e "$target" || -L "$target" ]]; then
        [[ ! -L "$target" && -d "$target/.git" ]] || fail "Not a source checkout: $target"
        [[ -z "$(git -C "$target" status --porcelain)" ]] || fail "Dirty checkout; leaving untouched: $target"
        git -C "$target" pull --ff-only >&2 || fail "Cannot fast-forward $target"
    else
        git clone --depth 1 "https://github.com/hakuimaku/$name.git" "$target" >&2 || fail "Cannot clone $name"
    fi
    printf '%s\n' "$target"
}
