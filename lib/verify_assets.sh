#!/usr/bin/env bash

verify_assets() {
    [[ -f "$HOME/.themes/Hikaide/index.theme" ]] || fail 'Hikaide installation missing'
    [[ -f "$HOME/.themes/Hikaide-Light/index.theme" ]] || fail 'Hikaide-Light installation missing'
    [[ -f "$HOME/.icons/Hikaide-Symbols/index.theme" ]] || fail 'Hikaide-Symbols installation missing'
    [[ -f "$HOME/.icons/Hikaide-Symbols-Light/index.theme" ]] || fail 'Hikaide-Symbols-Light installation missing'
    [[ -f "$HAKU_CURSOR_DIR/index.theme" ]] || fail 'Cursor installation missing'
}
