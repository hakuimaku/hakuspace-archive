#!/usr/bin/env bash
# Installation only. HakuSpace owns activation and runtime synchronization.
set -euo pipefail

ARCHIVE_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
for module in common source_repo install_cursor install_gtk_theme install_icons verify_assets cleanup_legacy_icon_accent; do
    source "$ARCHIVE_ROOT/lib/$module.sh"
done

case "${1:-}" in
    --help|-h)
        echo 'Usage: setup.sh [--no-wallpapers]'
        echo 'Install Haku Cursor, Hikaide, Hikaide-Symbols; copy wallpapers by default.'
        exit 0 ;;
    ''|--no-wallpapers) ;;
    *) fail "Unknown option: $1" ;;
esac

export PATH="$HOME/.local/bin:$PATH"
HAKU_CURSOR_SOURCE="$(source_repo haku-cursor "${HAKU_CURSOR_SOURCE:-}")"
HAKU_GTK_THEME_SOURCE="$(source_repo hikade-gtk-theme "${HAKU_GTK_THEME_SOURCE:-}")"
HAKU_ICON_THEME_SOURCE="$(source_repo hikaide-symbols "${HAKU_ICON_THEME_SOURCE:-}")"

install_cursor
install_gtk_theme
install_icons
verify_assets
cleanup_legacy_icon_accent
if [[ "${1:-}" != --no-wallpapers && -d "$ARCHIVE_ROOT/Wallpapers" ]]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp -an "$ARCHIVE_ROOT/Wallpapers/." "$HOME/Pictures/Wallpapers/"
fi
write_manifest
printf 'Haku visual assets installed. HakuSpace can now activate and synchronize them.\n'
