#!/usr/bin/env bash
# Installer-only migration: never remove an unverified/user-modified executable.
cleanup_legacy_icon_accent() {
    local receipt="$ASSET_STATE_DIR/icon-accent.sha256" name actual
    [[ -e "$receipt" || -L "$receipt" ]] || return 0
    if [[ -L "$receipt" || ! -f "$receipt" ]]; then
        printf 'assets: warning: unsafe legacy checksum receipt; files preserved\n' >&2
        return 0
    fi
    for name in icon-accent icon_accent.py; do
        if [[ -L "$HOME/.local/bin/$name" || ! -f "$HOME/.local/bin/$name" ]]; then
            printf 'assets: warning: legacy icon-accent missing or user-owned; files preserved\n' >&2
            return 0
        fi
    done
    actual="$(sha256sum "$HOME/.local/bin/icon-accent" "$HOME/.local/bin/icon_accent.py")" || {
        printf 'assets: warning: cannot verify both legacy files; files preserved\n' >&2
        return 0
    }
    # Compare the entire receipt, including both exact paths, not arbitrary entries.
    if [[ -n "$actual" ]] && cmp -s "$receipt" <(printf '%s\n' "$actual"); then
        rm -- "$HOME/.local/bin/icon-accent" "$HOME/.local/bin/icon_accent.py" "$receipt"
        printf 'assets: removed checksum-verified legacy icon-accent installation\n'
    else
        printf 'assets: warning: legacy icon-accent modified or user-owned; files preserved\n' >&2
    fi
}
