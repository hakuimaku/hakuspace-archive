#!/usr/bin/env bash

# Relaunch script within nix-shell if we are on NixOS or missing core tools
if { [ -f "/etc/nixos/configuration.nix" ] || ! command -v git >/dev/null 2>&1; } && [ -z "$IN_NIX_SHELL" ]; then
    if command -v nix-shell >/dev/null 2>&1; then
        echo ":: Nix environment detected. Relaunching with required tools (git, tar, gtk3)..."
        export IN_NIX_SHELL=1
        exec nix-shell -p git gnutar gtk3 --run "bash \"$0\" \"$@\""
    fi
fi

HAKU_DIR="$HOME/hakuspace-archive"
ICON_DIR="$HOME/.icons"
THEME_DIR="$HOME/.themes"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Ensure directories exist
mkdir -p "$ICON_DIR" "$THEME_DIR" "$WALLPAPER_DIR"

# Install Bibata Cursor
# https://github.com/ful1e5/Bibata_Cursor

echo ""
echo "Cursor Setup:"
read -p ">>> Do you want to install Bibata Cursor Theme? (y/n): " install_bibata
if [[ "$install_bibata" =~ ^[Yy]$ ]]; then
    echo ":: Installing Bibata Cursor Theme..."
    echo ":: Extracting Bibata Cursor Theme to ~/.icons/..."
    tar -xzf "$HAKU_DIR/Bibata-Modern-Ice.tar.gz" -C "$ICON_DIR"
fi


# Install Tela Icon Theme
# https://github.com/vinceliuice/Tela-icon-theme

echo ""
echo "Icons Setup:"
read -p ">>> Do you want to install Tela Icon Theme? (y/n): " install_tela
if [[ "$install_tela" =~ ^[Yy]$ ]]; then
    echo ":: Installing Tela Icon Theme..."
    echo ":: Cloning Tela Icon Theme repository..."
    git clone https://github.com/vinceliuice/Tela-icon-theme "$HAKU_DIR/Tela-icon-theme"
    echo ":: Installing Tela Icon Theme..."
    cd "$HAKU_DIR/Tela-icon-theme" || exit 1
    ./install.sh -d "$ICON_DIR" -c "black"
    cd - >/dev/null || exit 1
    rm -rf "$HAKU_DIR/Tela-icon-theme"
fi


# Install Midnight Theme
# https://github.com/i-mint/midnight

echo ""
echo "Theme (Widget) Setup:"
read -p ">>> Do you want to install Midnight Gray Theme? (y/n): " install_midnight
if [[ "$install_midnight" =~ ^[Yy]$ ]]; then
    echo ":: Installing Midnight Gray Theme..."
    echo ":: Cloning Midnight Theme repository..."
    git clone https://github.com/i-mint/midnight "$HAKU_DIR/midnight"
    echo ":: Copying Midnight Gray Theme to ~/.themes/..."
    cp -r "$HAKU_DIR/midnight/Midnight-Gray" "$THEME_DIR/"
    rm -rf "$HAKU_DIR/midnight"
fi

# Copy Wallpapers

echo ""
echo "Wallpaper Setup:"
read -p ">>> Do you want to copy wallpapers to ~/Pictures/Wallpapers/? (y/n): " copy_wallpapers
if [[ "$copy_wallpapers" =~ ^[Yy]$ ]]; then
    echo ":: Copying Wallpapers..."
    if [ -d "$HAKU_DIR/Wallpapers" ]; then
        cp -r "$HAKU_DIR/Wallpapers/"* "$WALLPAPER_DIR/"
    else
        echo "[!] Wallpapers folder not found in archive."
    fi
fi

echo ""
echo "Setup completed."