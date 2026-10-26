#!/usr/bin/env bash

install_icons() {
    local args=()
    if [[ -e "$HOME/.icons/Hikaide-Symbols" || -L "$HOME/.icons/Hikaide-Symbols" || \
          -e "$HOME/.icons/Hikaide-Symbols-Light" || -L "$HOME/.icons/Hikaide-Symbols-Light" ]]; then
        args=(--replace)
    fi
    # Upstream validates ownership even with --replace; never bypass that guard.
    (cd "$HAKU_ICON_THEME_SOURCE" && python3 scripts/build.py && python3 scripts/validate.py && ./scripts/install.sh "${args[@]}")
}
