<div align="center">

# Haku Space Assets Setup
Install Icons, Themes, and Wallpapers for Haku Space

</div>

<p align="center">
    <a href="https://archlinux.org/"><img alt="Arch Linux" src="https://img.shields.io/badge/Arch%20Linux-%231f1f1f?style=for-the-badge&logo=archlinux&logoColor=%231f1f1f&labelColor=%2368818f&color=%231f1f1f"></a>&nbsp;
    <a href="https://github.com/hakuimaku/hakuspace"><img alt="HakuSpace" src="https://img.shields.io/badge/HakuSpace-%231f1f1f?style=for-the-badge&logo=github&logoColor=%231f1f1f&labelColor=%2368818f&color=%231f1f1f"></a>&nbsp;
    <a href="https://github.com/hakuimaku/hakuspace/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/hakuimaku/hakuspace?style=for-the-badge&label=Stars&labelColor=%2368818f&color=%231f1f1f&logo=github&logoColor=%231f1f1f"></a>&nbsp;
</p>

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Welcome" alt="Typing SVG" />

This repository contains a **post-install setup script** for Haku Space visual assets:

- Mouse Cursor (Bibata)
- Icon Theme (Tela)
- GTK Theme (Midnight Gray)
- Wallpapers

> [!Important]
> This script is designed for users who already installed the main dotfiles from **Haku Space**.  
> Main repo: https://github.com/hakuimaku/hakuspace

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=What+this+script+does" alt="Typing SVG" />

`setup.sh` will interactively ask what you want to install:

1. **Bibata Cursor**
   - Option 1: Install full Bibata cursor package via `yay`
   - Option 2: Extract local `Bibata-Modern-Ice.tar.gz` from `~/hakuspace-archive`
   - Option 0: Skip

2. **Tela Icon Theme**
   - Clone `vinceliuice/Tela-icon-theme`
   - Run `install.sh` with black variant into `~/.icons`

3. **Midnight Gray Theme**
   - Clone `i-mint/midnight`
   - Copy `Midnight-Gray` into `~/.themes`

4. **Wallpapers**
   - Copy from `~/hakuspace-archive/Wallpapers` to `~/Pictures/Wallpapers`

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Requirements" alt="Typing SVG" />

- Arch Linux / Arch-based distro
- `bash`
- `git`
- `tar`
- `yay` (only required if you choose Bibata option 1)
- Local asset archive at: `~/hakuspace-archive`

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Installation+Guide" alt="Typing SVG" />

### 1. Clone this repository

```bash
cd ~
git clone https://github.com/<your-account>/<your-assets-repo>.git
cd <your-assets-repo>
```

### 2. Make script executable

```bash
chmod +x setup.sh
```

### 3. Run setup

```bash
./setup.sh
```

Follow the interactive prompts and select what you want to install.

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Install+Locations" alt="Typing SVG" />

- Icons: `~/.icons`
- Themes: `~/.themes`
- Wallpapers: `~/Pictures/Wallpapers`

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Troubleshooting" alt="Typing SVG" />

- If `yay` is missing, Bibata option 1 will fail.  
  Install `yay` first, or use Bibata option 2 (local tarball).
- If `git clone` fails, check your internet connection.
- If wallpapers/themes/icons are not copied, verify `~/hakuspace-archive` exists and contains required files.
- If anything breaks, run the script directly in terminal and read the exact error output.

---

## <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=32&pause=4000&color=68818F&center=false&vCenter=false&repeat=true&width=900&lines=Credits" alt="Typing SVG" />

- Cursor: [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor)
- Icons: [Tela Icon Theme](https://github.com/vinceliuice/Tela-icon-theme)
- Theme: [Midnight](https://github.com/i-mint/midnight)
- Main dotfiles project: [Haku Space](https://github.com/hakuimaku/hakuspace)

---

<div align="center">

### Just chill ✨

If you like this setup, give the main repo a ⭐

</div>

---

*Themes, Icons and Wallpapers used in Haku Space:*
- Theme: [Midnight-Gray](https://www.gnome-look.org/p/1273208)
- Icons: [Tela-black](https://www.gnome-look.org/p/1279924)
- Mouse Cursor: [Bibata-Modern-Ice](https://www.gnome-look.org/p/1197198)
- Wallpapers Artists:
  - [zrxrevolutionz](https://www.deviantart.com/zrxrevolutionz)
  - [かづいせ](https://www.pixiv.net/en/users/1031168)
  - [airfish 空气鱼](https://www.pixiv.net/en/users/67512705)
  - [Android/アンドロイド](https://www.pixiv.net/en/users/67750556)
  - [Roby0174](https://www.deviantart.com/roby0174)
  - [越前蟹参号](https://www.pixiv.net/en/users/98660769)
  - [mmAir](https://www.pixiv.net/en/users/39363802)
  - [ゲン助](https://www.pixiv.net/en/users/32008)

Themes, Icons and Wallpapers belong to their respective creators.