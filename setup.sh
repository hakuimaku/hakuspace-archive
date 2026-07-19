#!/bin/bash

HAKU_DIR="$HOME/hakuspace-archive"
ICON_DIR="$HOME/.icons"
THEME_DIR="$HOME/.themes"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

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
        echo ":: Installing Full Bibata Cursor Theme..."
        yay -S bibata-cursor-theme-bin
        ;;
    2)
        echo ":: Installing Bibata-Modern-Ice.tar.gz..."
        tar -xzf $HAKU_DIR/Bibata-Modern-Ice.tar.gz -C $ICON_DIR
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
    git clone https://github.com/vinceliuice/Tela-icon-theme $HAKU_DIR/Tela-icon-theme
    echo ":: Installing Tela Icon Theme..."
    cd $HAKU_DIR/Tela-icon-theme
    ./install.sh -d "$ICON_DIR" -c "black"
    cd -
    rm -rf $HAKU_DIR/Tela-icon-theme
fi


# Install Midnight Theme
# https://github.com/i-mint/midnight

echo ""
read -p ">>> Do you want to install Midnight Gray Theme? (y/n): " install_midnight
if [[ "$install_midnight" =~ ^[Yy]$ ]]; then
    echo ":: Installing Midnight Gray Theme..."
    echo ":: Cloning Midnight Theme repository..."
    git clone https://github.com/i-mint/midnight $HAKU_DIR/midnight
    echo ":: Copying Midnight Gray Theme to ~/.themes/..."
    cp -r $HAKU_DIR/midnight/Midnight-Gray $THEME_DIR/
    rm -rf $HAKU_DIR/midnight
fi

# Copy Wallpapers

echo ""
read -p ">>> Do you want to copy wallpapers to ~/Pictures/Wallpapers/? (y/n): " copy_wallpapers
if [[ "$copy_wallpapers" =~ ^[Yy]$ ]]; then
    echo ":: Copying Wallpapers..."
    mkdir -p $WALLPAPER_DIR
    cp -r $HAKU_DIR/Wallpapers/* $WALLPAPER_DIR/
fi

echo ""
echo "Setup completed."
