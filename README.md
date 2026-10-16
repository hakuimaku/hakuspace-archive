<div align="center">

# Haku Space Assets Setup
Install Icons, Themes, and Wallpapers for Haku Space

</div>

---

## Welcome

This repository contains a **post-install setup script** for Haku Space visual assets:

- [Haku Cursor](https://github.com/hakuimaku/haku-cursor) (default: Haku-Dark)
- [Hikaide GTK](https://github.com/hakuimaku/hikade-gtk-theme)
- [Hikaide-Symbols](https://github.com/hakuimaku/hikaide-symbols)
- Wallpapers

> [!Important]
> This script is designed for users who already installed the main dotfiles from **Haku Space**.  
> Main repo: https://github.com/hakuimaku/hakuspace

---

## Installation

Run `bash setup.sh` after installing HakuSpace core. Use `--no-wallpapers` to
skip copying wallpapers. Existing wallpaper files are preserved.

Requirements: Bash, Git, Make, Python 3, and the upstream cursor build dependencies
(`rsvg-convert` / `xcursorgen`, or Pillow for the supported fallback). On NixOS,
run inside a development shell providing these tools; the installer does not
install system packages.

Sources are shallow-cloned into `${XDG_CACHE_HOME:-$HOME/.cache}/hakuspace/assets-src/`.
Clean cached checkouts update with `git pull --ff-only`; dirty or divergent
checkouts are left untouched. Explicit source overrides are used as-is:

```bash
HAKU_CURSOR_SOURCE=~/haku-cursor \
HAKU_GTK_THEME_SOURCE=~/hikade-gtk-theme \
HAKU_ICON_THEME_SOURCE=~/hikaide-symbols bash setup.sh
```

The installer calls each project's build/validation/installation tools. It
refuses unmanaged Hikaide-Symbols, unrecognized GTK themes and unmarked cursor
directories. Previously installed Haku cursors without an archive ownership
marker must be preserved/moved out of the target before installation. Legacy
accent-engine files are preserved unless verified by their installation checksum receipt (see migration below).

| Installed asset | Location |
| --- | --- |
| Hikaide | `~/.themes/Hikaide` |
| Hikaide-Symbols | `~/.icons/Hikaide-Symbols` |
| Haku Cursor | `~/.icons/Haku-Dark` |
| Installation manifest | `~/.local/state/hakuspace/assets/installed.env` |

The exact cursor theme is configured with `HAKU_CURSOR_THEME` (default:
`Haku-Dark`) in the environment or
`${XDG_CONFIG_HOME:-$HOME/.config}/hakuspace/appearance.env`, shared with HakuSpace:

```bash
HAKU_CURSOR_THEME=Haku-Dark
# HAKU_CURSOR_THEME=Haku-Light
# HAKU_CURSOR_THEME=Haku-Blue-Light
```

Colour themes such as Haku-Blue/Haku-Blue-Light and Haku-Pink/Haku-Pink-Light
are optional. The installer resolves the name into one upstream build target and
style, then installs the exact theme selector under `~/.icons`. It never passes
a palette selector that could install both variants. Only the selected target's
ownership is checked/replaced; sibling variants are left untouched. Upstream
animation defaults are preserved.

Deprecated `HAKU_CURSOR_PALETTE=blue` remains a fallback for one compatibility
cycle, mapping to Haku-Blue (dark variant). Explicit theme wins over legacy
palette; when neither is configured the default is Haku-Dark. Prefer theme names
for new configuration. Old managed XDG installations are not moved or deleted.
The manifest records `HAKU_CURSOR_THEME`, `HAKU_CURSOR_PATH` and source revision;
these are installation metadata, not runtime state.

This repository owns **installation/update**, not activation. HakuSpace's
`scripts/assets.sh` runs this installer, verifies/selects appearance, then runs
`theme_ctl.sh apply` to reconcile the canonical accent. When running setup
standalone, run those HakuSpace commands afterward. The manifest is installation
metadata, never runtime theme state.

After installation, this checkout and the source cache can be deleted. Runtime
needs only installed assets and HakuSpace core/state. Safe icon recoloring is
implemented inside HakuSpace; this archive neither clones nor installs an accent
engine.
There is no watcher or daemon. Cursor builds and GTK CSS do not follow desktop
accent changes. HakuSpace decides which installed icons follow its accent.

## Legacy installation migration

On update, the installer checks the old
`~/.local/state/hakuspace/assets/icon-accent.sha256` receipt. It removes
`~/.local/bin/icon-accent`, `~/.local/bin/icon_accent.py` and that receipt only
when the receipt exactly matches both regular installed files and their paths.
Modified, missing, symlinked or unmanaged files are preserved; unsafe/mismatched
receipts produce a warning. This migration does not touch accent backups and
never runs at session startup. The new installation manifest has only cursor,
GTK and icon-theme metadata.

HakuSpace can opt out of icon management with `HAKU_ICON_THEME=system` or disable
recoloring with `HAKU_ICON_ACCENT_MODE=off`. Its default `auto` mode recolors only
managed Hikaide-Symbols; `on` explicitly opts in for compatible user-owned themes.
Those settings belong to HakuSpace runtime, not this asset installer.

## Tests

```bash
python3 -m unittest discover -s tests -v
# From a directory containing HakuSpace, this archive and the three asset sources:
HAKUSPACE_TEST_ASSET_REPOS="$PWD" python3 hakuspace/scripts/test_visual_ecosystem.py -v
```

The integration test uses a temporary HOME and local source overrides, exercises
fresh/update/reinstall/archive-removal paths, and never activates host settings.

## Credits

Themes, Icons and Wallpapers belong to their respective creators.

- GTK theme: [Hikaide](https://github.com/hakuimaku/hikade-gtk-theme)
- Icons: [Hikaide-Symbols](https://github.com/hakuimaku/hikaide-symbols)
- Cursor: [Haku Cursor](https://github.com/hakuimaku/haku-cursor)
- Wallpapers Artists:

<div align="center">

| Artist | Artworks |
|--------|----------|
| **[Android/アンドロイド](https://www.pixiv.net/en/users/67750556)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/12b670c3-5528-4f86-a219-7e6f1b483922" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/decb700f-70cb-43dd-965a-988020019a68" /> |
| **[airfish 空气鱼](https://www.pixiv.net/en/users/67512705)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/a1fedb03-36f0-401e-acd3-4a950431bc99" /> |
| **[ゲン助](https://www.pixiv.net/en/users/32008)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/0ce8ef6f-1dda-4db8-af70-a08ff2f1be3e" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/4f254259-ecbd-4900-8b36-4b833f5dbd4f" /> |
| **[mmAir](https://www.pixiv.net/en/users/39363802)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/d23e6cfc-d2fb-4f5c-bea6-7108b8c725e5" /> |
| **[越前蟹参号](https://www.pixiv.net/en/users/98660769)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/cb51761b-dcb9-44be-9849-a2f2e0a9b043" /> |
| **[かづいせ](https://www.pixiv.net/en/users/1031168)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/fe00efbf-a191-4c57-a3bc-cefc6e2c8e7b" /> |
| **[卡哇伊](https://www.pixiv.net/en/users/113500196)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/794268c1-5744-47ec-9f37-9baef569d679" /> |
| **[Gracile](https://www.pixiv.net/en/users/3434849)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/3f6a3fda-eb9d-4311-b65c-0a7a156d7b4c" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/8bc623d0-cb80-46d3-8195-11cb20bc5c72" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/fe057adf-4126-4ef4-8fd3-a8795d257d5b" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/77bb1bc5-6b1e-408c-abac-d02f16457a49" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/079c1c7f-969a-480d-91b6-e270e2d93602" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/1876a073-305d-42b4-8d46-abc7416c0cd7" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/e3fffc0d-4be5-44d3-8339-75fd50ce2712" /> |
| **[zrxrevolutionz](https://www.deviantart.com/zrxrevolutionz)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/8f86746b-a7fa-4e9b-bfe7-421cea7f1bb8" /> <img width="350" alt="image" src="https://github.com/user-attachments/assets/e554212f-ca32-4114-b9a0-a010f6307efd" /> |
| **[Roby0174](https://www.deviantart.com/roby0174)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/1c6b5ef2-26b9-4aab-9105-f343fbb397f5" /> |
| **[Mk](https://www.pixiv.net/en/users/103781220)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/fc00c4ea-45d5-4347-9f75-b7de72df4324" /> |
| **[茶杯雨、](https://www.pixiv.net/en/users/80531324)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/da4e9466-0313-4951-ba92-02ea89129460" /> |
| **[Toilet_chicken](https://www.pixiv.net/en/users/61332935)**  | <img width="350" alt="image" src="https://github.com/user-attachments/assets/de5c9ba9-55b0-4ef6-a6d0-daf892772b26" /> |
| **[邦乔彦](https://www.pixiv.net/en/users/10746425)** | <img width="350" alt="image" src="https://github.com/user-attachments/assets/2e10e9a2-4226-4805-87bc-5ac45854fb07" /> |
| **[Nona](https://www.pixiv.net/en/users/110945671)** | <img width="350" alt="148907461_p0" src="https://github.com/user-attachments/assets/ee347dbe-c391-47e0-b76c-aabf2e9fb9c2" /> |
| **[りゃね](https://www.pixiv.net/en/users/120015975)**  | <img width="350" alt="image" src="https://github.com/user-attachments/assets/a2610939-3e01-4aa0-923f-b37f38404a22" /> |
| **[瑜璟](https://www.pixiv.net/en/users/73110986)** | <img width="350" alt="98338327_p0" src="https://github.com/user-attachments/assets/6b87a98c-226a-4e26-98cf-b347dda61593" /> |
| unknown | <img width="350" alt="image" src="https://github.com/user-attachments/assets/7d490fb5-fea6-4ce7-a6c6-42dd218db194" /> |

</div>
