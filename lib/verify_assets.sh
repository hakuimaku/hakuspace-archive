#!/usr/bin/env bash

verify_assets() {
    [[ -f "$HOME/.themes/Hikaide/index.theme" ]] || fail 'Hikaide installation missing'
    [[ -f "$HOME/.icons/Hikaide-Symbols/index.theme" ]] || fail 'Hikaide-Symbols installation missing'
    [[ -f "$HAKU_CURSOR_DIR/index.theme" ]] || fail 'Cursor installation missing'
}
