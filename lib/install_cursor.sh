#!/usr/bin/env bash

install_cursor() {
    resolve_cursor_theme
    local target="$HAKU_CURSOR_DIR"
    if [[ -e "$target" || -L "$target" ]]; then
        [[ ! -L "$target" && -f "$target/.hakuspace-cursor" && ! -L "$target/.hakuspace-cursor" ]] &&
            [[ "$(cat "$target/.hakuspace-cursor")" == 'HakuSpace managed cursor v1' ]] ||
            fail "Refusing to overwrite an unmanaged cursor: $target"
    fi
    (
        cd "$HAKU_CURSOR_SOURCE" || exit 1
        make "$CURSOR_BUILD_TARGET" STYLE="$CURSOR_STYLE" && make verify || exit 1
        # Upstream falls back to palette selectors if an exact directory is absent.
        [[ -d "dist/$HAKU_CURSOR_THEME/cursors" && -f "dist/$HAKU_CURSOR_THEME/index.theme" ]] ||
            fail "Selected cursor was not built: $HAKU_CURSOR_THEME"
        make install THEME="$HAKU_CURSOR_THEME"
    ) || return 1
    [[ -f "$target/index.theme" && -d "$target/cursors" ]] || fail "Cursor installation missing: $target"
    printf 'HakuSpace managed cursor v1\n' > "$target/.hakuspace-cursor"
}
