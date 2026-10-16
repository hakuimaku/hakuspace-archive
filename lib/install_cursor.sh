#!/usr/bin/env bash

install_cursor() {
    [[ "$HAKU_CURSOR_PALETTE" =~ ^[a-z]+$ ]] || fail 'Invalid cursor palette'
    CURSOR_NAME="Haku-${HAKU_CURSOR_PALETTE^}"
    local target="${XDG_DATA_HOME:-$HOME/.local/share}/icons/$CURSOR_NAME"
    if [[ -e "$target" || -L "$target" ]]; then
        [[ ! -L "$target" && -f "$target/.hakuspace-cursor" && ! -L "$target/.hakuspace-cursor" ]] &&
            [[ "$(cat "$target/.hakuspace-cursor")" == 'HakuSpace managed cursor v1' ]] ||
            fail "Refusing to overwrite an unmanaged cursor: $target"
    fi
    (cd "$HAKU_CURSOR_SOURCE" && make "$HAKU_CURSOR_PALETTE" && make verify && make install THEME="$HAKU_CURSOR_PALETTE")
    printf 'HakuSpace managed cursor v1\n' > "$target/.hakuspace-cursor"
}
