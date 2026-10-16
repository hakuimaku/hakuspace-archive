#!/usr/bin/env bash

verify_assets() {
    [[ -f "$HOME/.themes/Hikaide/index.theme" ]] || fail 'Hikaide installation missing'
    [[ -f "$HOME/.icons/Hikaide-Symbols/index.theme" ]] || fail 'Hikaide-Symbols installation missing'
    [[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/$CURSOR_NAME/index.theme" ]] || fail 'Cursor installation missing'
}
