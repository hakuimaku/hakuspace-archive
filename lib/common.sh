#!/usr/bin/env bash

ASSET_SOURCE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hakuspace/assets-src"
ASSET_STATE_DIR="$HOME/.local/state/hakuspace/assets"
# Shared user overrides are also read by HakuSpace's appearance contract.
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/hakuspace/appearance.env" ]]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/hakuspace/appearance.env"
fi
# Legacy palettes retain their dark variant for one compatibility cycle.
if [[ -z "${HAKU_CURSOR_THEME:-}" && -n "${HAKU_CURSOR_PALETTE:-}" ]]; then
    HAKU_CURSOR_THEME="Haku-${HAKU_CURSOR_PALETTE^}"
fi
HAKU_CURSOR_THEME="${HAKU_CURSOR_THEME:-Haku-Dark}"
HAKU_CURSOR_DIR="$HOME/.icons/$HAKU_CURSOR_THEME"

fail() { printf 'assets: %s\n' "$*" >&2; exit 1; }

resolve_cursor_theme() {
    local preset
    case "$HAKU_CURSOR_THEME" in
        Haku-Dark) CURSOR_BUILD_TARGET=dark; CURSOR_STYLE=dark ;;
        Haku-Light) CURSOR_BUILD_TARGET=light; CURSOR_STYLE=light ;;
        Haku-*)
            preset="${HAKU_CURSOR_THEME#Haku-}"
            CURSOR_STYLE=dark
            if [[ "$preset" == *-Light ]]; then
                preset="${preset%-Light}"
                CURSOR_STYLE=light
            fi
            [[ "$preset" =~ ^[A-Z][a-zA-Z0-9]*$ ]] || fail "Invalid cursor theme: $HAKU_CURSOR_THEME"
            CURSOR_BUILD_TARGET="${preset,,}"
            ;;
        *) fail "Invalid cursor theme: $HAKU_CURSOR_THEME" ;;
    esac
}

write_manifest() {
    local temporary key source
    mkdir -p "$ASSET_STATE_DIR"
    temporary="$(mktemp "$ASSET_STATE_DIR/installed.env.XXXXXX")"
    {
        printf 'HAKU_CURSOR_INSTALLED=1\nHAKU_CURSOR_THEME=%q\n' "$HAKU_CURSOR_THEME"
        printf 'HAKU_CURSOR_PATH=%q\n' "$HAKU_CURSOR_DIR"
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
