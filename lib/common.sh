#!/usr/bin/env bash

ASSET_SOURCE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hakuspace/assets-src"
ASSET_STATE_DIR="$HOME/.local/state/hakuspace/assets"
# Shared user overrides are also read by HakuSpace's appearance contract.
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hakuspace/appearance.env" ]]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/hakuspace/appearance.env"
fi
HAKU_CURSOR_PALETTE="${HAKU_CURSOR_PALETTE:-blue}"

fail() { printf 'assets: %s\n' "$*" >&2; exit 1; }

write_manifest() {
    local temporary key source
    mkdir -p "$ASSET_STATE_DIR"
    temporary="$(mktemp "$ASSET_STATE_DIR/installed.env.XXXXXX")"
    {
        printf 'HAKU_CURSOR_INSTALLED=1\nHAKU_CURSOR_THEME=%q\n' "$CURSOR_NAME"
        printf 'HAKU_GTK_THEME_INSTALLED=1\nHAKU_GTK_THEME=Hikaide\n'
        printf 'HAKU_ICON_THEME_INSTALLED=1\nHAKU_ICON_THEME=Hikaide-Symbols\n'
        printf 'HAKU_ICON_THEME_DIR=%q\n' "$HOME/.icons"
        for key in CURSOR GTK_THEME ICON_THEME; do
            source="HAKU_${key}_SOURCE"
            printf 'HAKU_%s_REV=%q\n' "$key" "$(git -C "${!source}" rev-parse HEAD)"
        done
    } > "$temporary"
    mv -f "$temporary" "$ASSET_STATE_DIR/installed.env"
}
