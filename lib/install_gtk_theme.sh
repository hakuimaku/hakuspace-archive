#!/usr/bin/env bash

install_gtk_theme() {
    python3 "$HAKU_GTK_THEME_SOURCE/scripts/install_gtk_theme.py" --dest "$HOME/.themes"
}
