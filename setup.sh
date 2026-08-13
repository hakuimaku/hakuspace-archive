#!/usr/bin/env bash

# Relaunch script within nix-shell if we are on NixOS or missing core tools
if { [ -f "/etc/nixos/configuration.nix" ] || ! command -v git >/dev/null 2>&1; } && [ -z "$IN_NIX_SHELL" ]; then
    if command -v nix-shell >/dev/null 2>&1; then
        echo ":: Nix environment detected. Relaunching with required tools (git, tar, gtk3)..."
        export IN_NIX_SHELL=1
        exec nix-shell -p git tar gtk3 --run "bash \"$0\" \"$@\""
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

echo "Installing Mouse Cursor: Bibata Cursor Theme..."
echo ""
echo " [1]. Full icons (yay -S bibata-cursor-theme-bin, source) - full set of icons"
echo " [2]. Bibata-Modern-Ice.tar.gz (from hakuspace-archive) - only one icon set"
echo " [0]. Skip installation"
echo ""

read -p ">>> Select an option (1 or 2): " cursor_choice
case $cursor_choice in
    1)
        if command -v yay >/dev/null 2>&1; then
            echo ":: Installing Full Bibata Cursor Theme..."
            yay -S bibata-cursor-theme-bin
        else
            echo "[!] 'yay' is not installed (NixOS detected?)."
            echo ":: Please add 'bibata-cursors' directly to your Nix configuration (e.g., configuration.nix or flake.nix)."
        fi
        ;;
    2)
        echo ":: Installing Bibata-Modern-Ice.tar.gz..."
        if [ -f "$HAKU_DIR/Bibata-Modern-Ice.tar.gz" ]; then
            tar -xzf "$HAKU_DIR/Bibata-Modern-Ice.tar.gz" -C "$ICON_DIR"
        else
            echo "[!] Archive not found: $HAKU_DIR/Bibata-Modern-Ice.tar.gz"
        fi
        ;;
    0)
        echo ":: Skipping Bibata Cursor installation."
        ;;
    *)
        echo "[!] Invalid option. Please select 1 or 2."
        exit 1
        ;;
esac

# Install Tela Icon Theme
# https://github.com/vinceliuice/Tela-icon-theme

echo ""
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